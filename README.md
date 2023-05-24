# AWS serverless components provisioning with terraform

in this task we are provisioning two Simple Queue Service, 1. Main Queue, 2. Dead Letter Queue
and a Lambda function to handle and process main queue events, We also need a IAM role for lambda
function to process the queue.

here we are considering the use of workspace, different environments for dev, prod, qa, and stage.
Steps.
- Provision an IAM role for lambda funcition
- Provision a lambdra function
- Provision a Simple Queue main queue
- Provision another queue as Dead Letter Queue
- Create mapping between lambda function and simple queue.

Architecture diagram
```mermaid