$amazon_api_client = Vacuum.new
$amazon_api_client.configure(
      aws_access_key_id: ENV["AWS_SECRET_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      associate_tag: 'amaprime00-20'
    )