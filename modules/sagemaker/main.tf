###############################################################################
# SageMaker Notebook インスタンス
###############################################################################
resource "aws_sagemaker_notebook_instance" "this" {
  name           = "${var.project_name}-notebook"
  instance_type  = var.notebook_instance_type
  role_arn       = var.sagemaker_execution_role_arn
  tags = {
    Name = "${var.project_name}-notebook"
  }
}

###############################################################################
# SageMaker Training Job
###############################################################################
# resource "aws_sagemaker_training_job" "this" {
#   name     = "${var.project_name}-training"
#   role_arn = var.sagemaker_execution_role_arn
#
#   training_image    = var.training_image
#   training_job_name = "${var.project_name}-training"
#
#   input_data_config {
#     channel_name = "training"
#     data_source {
#       s3_data_source {
#         s3_data_type              = "S3Prefix"
#         s3_uri                    = var.training_data_s3_uri
#         s3_data_distribution_type = "FullyReplicated"
#       }
#     }
#     content_type = "text/csv"
#   }
#
#   output_data_config {
#     s3_output_path = var.training_output_s3_uri
#   }
#
#   resource_config {
#     instance_count    = var.training_instance_count
#     instance_type     = var.training_instance_type
#     volume_size_in_gb = var.training_volume_size
#   }
#
#   stopping_condition {
#     max_runtime_in_seconds = var.training_max_run_seconds
#   }
#
#   tags = {
#     Name = "${var.project_name}-training"
#   }
# }
#
# ###############################################################################
# # SageMaker Model 作成
# ###############################################################################
# resource "aws_sagemaker_model" "this" {
#   name               = "${var.project_name}-model"
#   execution_role_arn = var.sagemaker_execution_role_arn
#
#   primary_container {
#     image          = var.training_image
#     model_data_url = aws_sagemaker_training_job.this.model_artifacts[0]
#   }
#
#   tags = {
#     Name = "${var.project_name}-model"
#   }
# }
#
# ###############################################################################
# # SageMaker Endpoint Configuration
# ###############################################################################
# resource "aws_sagemaker_endpoint_configuration" "this" {
#   name = "${var.project_name}-endpoint-config"
#
#   production_variants {
#     variant_name           = "AllTraffic"
#     model_name             = aws_sagemaker_model.this.name
#     initial_instance_count = var.endpoint_instance_count
#     instance_type          = var.endpoint_instance_type
#   }
#
#   tags = {
#     Name = "${var.project_name}-endpoint-config"
#   }
# }
#
# ###############################################################################
# # SageMaker Endpoint
# ###############################################################################
# resource "aws_sagemaker_endpoint" "this" {
#   name                  = "${var.project_name}-endpoint"
#   endpoint_config_name  = aws_sagemaker_endpoint_configuration.this.name
#
#   tags = {
#     Name = "${var.project_name}-endpoint"
#   }
# }