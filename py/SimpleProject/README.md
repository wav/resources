## Getting Started

The following assumes python 3.4 or later.

Update `./bin/activate` with the appropriate `pyvenv`, currently expects `pyvenv-3.4` to be on PATH

# Activate the environment
```
chmod +x ./bin/activate
. ./bin/activate
```
# Run tests and the main module
```
python -m unittest SimpleProject.Test
python -m SimpleProject
```
# Add install some libraries and save
```
pip install 'biopython==1.64'
pip install -e 'git+https://github.com/wav/templates.git#egg=ExampleProject&subdirectory=py/ExampleProject'
pip freeze > requirements.txt
```
# Install from the requirements file
```
pip install -r requirements.txt
```