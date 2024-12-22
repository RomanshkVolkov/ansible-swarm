create-venv:
	python3 -m venv .venv
	. ./.venv/bin/activate && pip install -r requirements.txt

load-env:
	source ./.venv/bin/activate

create-ansible-test:
	ansible-playbook ansible/playbooks/test.yml -i ansible/inventory.ini

config-server:
	ansible-playbook ansible/playbooks/config-server-swarm.yml -i ansible/inventory.ini
