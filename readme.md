
```
# crea un entorno virtual
python3 -m venv .venv

# carga el entorno virtual
source .venv/bin/activate

# instala las herramientas necesarias
pip install -r requirements.txt

# recuerda cambiar el nombre del archivo inventory.ini.example a inventory.ini
# y hacer los reemplazos correspondientes
# ahora podras usar el test o el config-server como playbook usando las herramientas del entorno virtual

ansible-playbook ansible/playbooks/config-server-swarm.yml -i ansible/inventory.ini
```

