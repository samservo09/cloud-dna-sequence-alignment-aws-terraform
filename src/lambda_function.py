import json
import boto3
import os
from io import StringIO
from datetime import datetime
import logging

# Import Biopython modules (will be in Lambda layer)
try:
    from Bio import SeqIO, Align
    from Bio.Seq import Seq
    from Bio.SeqRecord import SeqRecord
except ImportError as e:
    print(f"Biopython import error: {e}")

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    """
    Main Lambda handler for DNA sequence alignment
    Triggered by S3 uploads or API Gateway requests
    """
    
    try:
        # Parse input based on trigger type
        if 'Records' in event:
            # S3 trigger
            return handle_s3_trigger(event, context)
        else:
            # API Gateway trigger
            return handle_api_request(event, context)
            
    except Exception as e:
        logger.error(f"Error in lambda_handler: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }

def handle_s3_trigger(event, context):
    """Handle S3 upload trigger"""
    
    results = []
    
    for record in event['Records']:
        # Get S3 bucket and object information
        bucket_name = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']
        
        logger.info(f"Processing file: s3://{bucket_name}/{object_key}")
        
        try:
            # Skip non-FASTA files
            if not object_key.lower().endswith(('.fasta', '.fa', '.fas')):
                logger.info(f"Skipping non-FASTA file: {object_key}")
                continue
                
            # Process the uploaded file
            result = process_sequence_file(bucket_name, object_key)
            results.append(result)
            
        except Exception as e:
            logger.error(f"Error processing {object_key}: {str(e)}")
            results.append({
                'file': object_key,
                'status': 'error',
                'error': str(e)
            })
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'Processed {len(results)} files',
            'results': results
        })
    }

def handle_api_request(event, context):
    """Handle API Gateway request"""
    
    try:
        # Parse request body
        if event.get('body'):
            body = json.loads(event['body'])
        else:
            body = event
            
        # Extract parameters
        sequence1 = body.get('sequence1', '')
        sequence2 = body.get('sequence2', '')
        alignment_type = body.get('alignment_type', 'global').lower()
        file_key = body.get('file_key', '')
        
        # Validate input
        if not sequence1 and not file_key:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Missing required parameter',
                    'message': 'Provide either sequence1 or file_key'
                })
            }
        
        # Process sequences
        if file_key:
            # Process file from S3
            bucket_name = os.environ.get('INPUT_BUCKET', 'dna-alignment-input')
            result = process_sequence_file(bucket_name, file_key, alignment_type)
        else:
            # Process direct sequence input
            result = align_sequences_direct(sequence1, sequence2, alignment_type)
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(result)
        }
        
    except json.JSONDecodeError:
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Invalid JSON',
                'message': 'Request body must be valid JSON'
            })
        }

def process_sequence_file(bucket_name, object_key, alignment_type='global'):
    """Process FASTA file from S3"""
    
    try:
        # Download file from S3
        response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
        file_content = response['Body'].read().decode('utf-8')
        
        # Parse FASTA sequences
        sequences = list(SeqIO.parse(StringIO(file_content), 'fasta'))
        
        if len(sequences) < 2:
            return {
                'file': object_key,
                'status': 'error',
                'error': 'File must contain at least 2 sequences for alignment'
            }
        
        # Perform alignment between first two sequences
        seq1 = sequences[0]
        seq2 = sequences[1]
        
        alignment_result = perform_alignment(seq1.seq, seq2.seq, alignment_type)
        
        # Prepare result
        result = {
            'file': object_key,
            'status': 'success',
            'alignment_type': alignment_type,
            'sequence1': {
                'id': seq1.id,
                'description': seq1.description,
                'length': len(seq1.seq)
            },
            'sequence2': {
                'id': seq2.id,
                'description': seq2.description,
                'length': len(seq2.seq)
            },
            'alignment': alignment_result,
            'timestamp': datetime.utcnow().isoformat()
        }
        
        # Save result to S3
        output_bucket = os.environ.get('OUTPUT_BUCKET', 'dna-alignment-results')
        output_key = f"results/{object_key.replace('.fasta', '')}_alignment_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.json"
        
        s3_client.put_object(
            Bucket=output_bucket,
            Key=output_key,
            Body=json.dumps(result, indent=2),
            ContentType='application/json'
        )
        
        result['output_location'] = f"s3://{output_bucket}/{output_key}"
        
        return result
        
    except Exception as e:
        logger.error(f"Error processing file {object_key}: {str(e)}")
        raise

def align_sequences_direct(sequence1, sequence2, alignment_type='global'):
    """Align sequences provided directly as strings"""
    
    # Convert strings to Seq objects
    seq1 = Seq(sequence1.upper())
    seq2 = Seq(sequence2.upper())
    
    # Perform alignment
    alignment_result = perform_alignment(seq1, seq2, alignment_type)
    
    return {
        'status': 'success',
        'alignment_type': alignment_type,
        'sequence1': {
            'length': len(seq1),
            'sequence': str(seq1)[:100] + ('...' if len(seq1) > 100 else '')
        },
        'sequence2': {
            'length': len(seq2),
            'sequence': str(seq2)[:100] + ('...' if len(seq2) > 100 else '')
        },
        'alignment': alignment_result,
        'timestamp': datetime.utcnow().isoformat()
    }

def perform_alignment(seq1, seq2, alignment_type='global'):
    """Perform sequence alignment using Biopython"""
    
    try:
        # Create aligner
        aligner = Align.PairwiseAligner()
        
        # Configure alignment parameters based on type
        if alignment_type.lower() == 'local':
            aligner.mode = 'local'
            aligner.match_score = 2
            aligner.mismatch_score = -1
            aligner.open_gap_score = -2
            aligner.extend_gap_score = -0.5
        else:  # global
            aligner.mode = 'global'
            aligner.match_score = 1
            aligner.mismatch_score = -1
            aligner.open_gap_score = -1
            aligner.extend_gap_score = -0.1
        
        # Perform alignment
        alignments = aligner.align(seq1, seq2)
        best_alignment = alignments[0]  # Get best alignment
        
        # Format alignment for output
        alignment_str = str(best_alignment)
        alignment_lines = alignment_str.split('\n')
        
        return {
            'score': float(best_alignment.score),
            'alignment_length': len(best_alignment),
            'identity': calculate_identity(best_alignment),
            'alignment_display': alignment_lines[:6],  # First 6 lines for display
            'full_alignment_length': len(alignment_lines)
        }
        
    except Exception as e:
        logger.error(f"Alignment error: {str(e)}")
        return {
            'error': f"Alignment failed: {str(e)}"
        }

def calculate_identity(alignment):
    """Calculate sequence identity percentage"""
    
    try:
        # Get aligned sequences
        aligned_seq1 = alignment.aligned[0]
        aligned_seq2 = alignment.aligned[1]
        
        # Count matches
        matches = 0
        total_length = 0
        
        for i in range(len(aligned_seq1)):
            seq1_segment = aligned_seq1[i]
            seq2_segment = aligned_seq2[i]
            
            # Compare segments
            for j in range(len(seq1_segment)):
                if j < len(seq2_segment):
                    if seq1_segment[j] == seq2_segment[j]:
                        matches += 1
                    total_length += 1
        
        if total_length == 0:
            return 0.0
            
        return round((matches / total_length) * 100, 2)
        
    except Exception as e:
        logger.error(f"Identity calculation error: {str(e)}")
        return 0.0

# Health check endpoint
def health_check():
    """Health check for the Lambda function"""
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'status': 'healthy',
            'service': 'DNA Sequence Alignment',
            'timestamp': datetime.utcnow().isoformat()
        })
    }