provider "aws" {
  region = "eu-west-2"  # Set your desired AWS region
}

resource "aws_s3_bucket" "example_bucket" {
  count = "${length(var.existing_s3_bucket_name)}"
  bucket      = var.existing_s3_bucket_name[count.index]
  # Add other S3 bucket configurations as needed
}


resource "aws_s3_bucket_notification" "my-trigger" {
  count = "${length(var.existing_s3_bucket_name)}"
  bucket      = var.existing_s3_bucket_name[count.index]
  eventbridge = true
    lambda_function {
        lambda_function_arn = "${aws_lambda_function.my_function.arn}"
        events              = ["s3:ObjectCreated:*"]
    }
    depends_on = [aws_lambda_permission.allow_bucket]
    
    /*topic {
    topic_arn     = aws_sns_topic.alert_sns.arn
    events        = ["s3:ObjectCreated:*"]
    }
    */
}


data "archive_file" "my_lambda_function" {
  source_file  = "${path.module}/functions/lambda.py"
  output_path = "${path.module}/functions/lambda.py.zip"
  type        = "zip"
}

resource "aws_lambda_permission" "allow_bucket" {
  count = "${length(var.existing_s3_bucket_name)}"
  statement_id  = "AllowS3Invoke-${var.existing_s3_bucket_name[count.index]}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_function.function_name
  principal = "s3.amazonaws.com"
  source_arn = "arn:aws:s3:::${var.existing_s3_bucket_name[count.index]}"
}

resource "aws_lambda_function" "my_function" {
   filename = data.archive_file.my_lambda_function.output_path
   source_code_hash = data.archive_file.my_lambda_function.output_base64sha256
   function_name = "my_function"
   role = "${aws_iam_role.lambda_execution_role.arn}"
   handler = "lambda.lambda_handler"
   runtime = "python3.9"
   timeout = 60

   environment {
     variables = {
      SNS_TOPIC_ARN = aws_sns_topic.alert_sns.arn
     }
   }
   }

