import boto3
import parasail
import os
import time
from Bio import SeqIO

# Initialize AWS clients
s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
# This table name MUST match the one you created in your Terraform file
DYNAMODB_TABLE_NAME = 'dna-alignment-jobs'

def handler(event, context):
    """
    This function is triggered by an S3 upload, aligns two sequences
    from the uploaded FASTA file, and saves the score to DynamoDB.
    """
    
    # 1. Get S3 bucket and key from the event
    try:
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        
        # S3 keys can have '+' signs that are URL-encoded
        key = key.replace('+', ' ')
        
        # Get just the filename (e.g., "compare_pair_001.fasta")
        filename = os.path.basename(key)
        
        # Set a temporary download path
        download_path = f'/tmp/{filename}'
        
        print(f'New file detected: {filename} from bucket {bucket}')

    except Exception as e:
        print(f"Error parsing S3 event: {e}")
        return {'status': 500, 'body': 'Error parsing event'}

    try:
        # 2. Download the FASTA file from S3
        print(f'Downloading {key} to {download_path}...')
        s3.download_file(bucket, key, download_path)
        
        # 3. Read the two sequences from the file using biopython
        print('Parsing FASTA file...')
        sequences = []
        for record in SeqIO.parse(download_path, 'fasta'):
            sequences.append(str(record.seq))
        
        if len(sequences) < 2:
            print(f"Error: File {filename} contains fewer than 2 sequences.")
            return {'status': 400, 'body': 'File must contain 2 sequences.'}
        
        seq1 = sequences[0]
        seq2 = sequences[1]
        
        # 4. Perform the alignment using parasail
        print('Performing alignment...')
        # (This is your logic from the template)
        # Using Needleman-Wunsch (global) stats. 10=match, 1=mismatch, blosum62 matrix
        result = parasail.sg_stats_striped_16(seq1, seq2, 10, 1, parasail.blosum62)
        score = result.score
        print(f'Alignment complete. Score: {score}')
        
        # 5. Save metadata to DynamoDB
        print('Saving results to DynamoDB...')
        table = dynamodb.Table(DYNAMODB_TABLE_NAME)
        
        table.put_item(
            Item={
                'filename': filename,
                'alignment_score': int(score),
                'timestamp': int(time.time())
            }
        )

        print('Job complete.')
        return {'status': 200, 'score': score}

    except Exception as e:
        print(f"Error during processing: {e}")
        # Optionally, you could write an error status to DynamoDB here
        return {'status': 500, 'body': 'Error during processing'}