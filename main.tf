
# provision a iam role for lambda function

resource "aws_iam_role" "lambda_role" {
  name = "labda_role_${terraform.workspace}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

  tags = {
    "Environment" = terraform.workspace
  }
}


# provision a lambda function
resource "aws_lambda_function" "process_queue_lambda" {
  filename         = "main.zip"
  function_name    = "${var.lambda_name}-${terraform.workspace}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = "data.archive_file.myzip.output_base64sha256"

  tags = {
    "Environment" = terraform.workspace
  }
}

# provision a simple queue with redrive policy for DLQ
resource "aws_sqs_queue" "main_queue" {
  name                      = "my-main-queue_${terraform.workspace}"
  delay_seconds             = 90
  max_message_size          = 262144
  message_retention_seconds = 86400 # 24 hrs msgs can be in queue
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn

    maxReceiveCount = 4 #number of times a consumer tries receiving a message from a queue without deleting it before being moved to the dead-letter queue.
  })

  tags = {
    "Environment" = terraform.workspace
  }
}

# provision another simple queue, which acts as a DLQ
resource "aws_sqs_queue" "dlq" { # dead letter queue
  name             = "dlq_${terraform.workspace}"
  delay_seconds    = 30     # delay between delivery
  max_message_size = 262144 # 256 KiB, default value

  tags = {
    "Environment" = terraform.workspace
  }

}

# create a mapping between queue event and lambda function
resource "aws_lambda_event_source_mapping" "sqs-lambda-trigger" {
  event_source_arn = aws_sqs_queue.main_queue.arn
  function_name    = aws_lambda_function.process_queue_lambda.arn
}