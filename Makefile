tf_bin=../terraform/terraform
terraform:
	$(tf_bin) get
	# terraform get
	for i in $$(ls .terraform/modules/*/Makefile); do f=$$(dirname $$i); make -C $$f; done
	$(tf_bin) validate
