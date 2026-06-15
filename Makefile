PY?=python3
PELICAN?=pelican
PELICANOPTS=

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/output
CONFFILE=$(BASEDIR)/pelicanconf.py
PUBLISHCONF=$(BASEDIR)/publishconf.py

S3_BUCKET=www.devops-consulting.link

DEBUG ?= 0
ifeq ($(DEBUG), 1)
	PELICANOPTS += -D
endif

RELATIVE ?= 0
ifeq ($(RELATIVE), 1)
	PELICANOPTS += --relative-urls
endif

help:
	@echo 'Makefile for DevOps Consulting Pelican site                                '
	@echo '                                                                           '
	@echo 'Usage:                                                                     '
	@echo '   make configure                      populate config from config.env      '
	@echo '   make html                           (re)generate the web site           '
	@echo '   make clean                          remove the generated files          '
	@echo '   make regenerate                     regenerate files upon modification  '
	@echo '   make publish                        generate using production settings  '
	@echo '   make serve [PORT=8000]              serve site at http://localhost:8000  '
	@echo '   make s3_upload                      upload the web site via S3          '
	@echo '   make init                           terraform init                      '
	@echo '   make plan                           terraform plan                      '
	@echo '   make apply                          terraform apply                     '
	@echo '   make remote-state                   bootstrap terraform remote state    '
	@echo '                                                                           '

configure:
	$(BASEDIR)/scripts/configure.sh $(BASEDIR)/config.env

html:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

clean:
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)

regenerate:
	$(PELICAN) -r $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

serve:
ifdef PORT
	cd $(OUTPUTDIR) && $(PY) -m http.server $(PORT)
else
	cd $(OUTPUTDIR) && $(PY) -m http.server
endif

publish:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(PUBLISHCONF) $(PELICANOPTS)

s3_upload: publish
	aws s3 sync $(OUTPUTDIR)/ s3://$(S3_BUCKET) --delete
	@echo "Deployed to s3://$(S3_BUCKET)"

init plan apply validate:
	make -C ./terraform/aws $@

plan: init
apply: init

remote-state:
	make -C ./terraform/aws-remote-state/ init validate plan apply

.PHONY: configure html help clean regenerate serve publish s3_upload init plan apply validate remote-state
