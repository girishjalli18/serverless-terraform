import json

def lambda_handler(event, context):
    for k, v in event.items():
        print(f"An Event occured : {k} {v}")

    return {
        'statusCode': 200,
        'body': json.dumps('Welcome to labda world!')
    }
