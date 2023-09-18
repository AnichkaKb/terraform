output "myelasticapp"{
  value = aws_elastic_beanstalk_application.myelasticapp.name
}

output "myelasticappenv"{
  value = aws_elastic_beanstalk_environment.myelasticappenv.name
}
