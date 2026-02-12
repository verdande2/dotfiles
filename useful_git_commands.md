https://stackoverflow.com/questions/79699897/how-to-uv-add-git-repo-with-subpackages

git submodule update --init

git submodule foreach "uv pip install -e ."


uv add "python_utilities @ git+https://github.com/verdande2/python_utilities.git"

run uv sync --upgrade to allow git packages like python_utilities to be updated with a pull






# init and update submodules after a fresh clone
git submodule update --init --recursive

# better version of clone, will recursively clone submodules
git clone --recursive [url]



git submodule update --init --recursive --remote
git submodule status


git submodule foreach 'git fetch && git checkout main && git pull'
