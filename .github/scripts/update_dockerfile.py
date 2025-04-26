import sys
import re
from packaging import version

# Read versions from the file
with open(sys.argv[1], 'r') as f:
    lines = f.readlines()
comfyui_version = None
manager_version = None
for line in lines:
    if line.startswith('COMFYUI_VERSION='):
        comfyui_version = line.strip().split('=', 1)[1]
    if line.startswith('MANAGER_VERSION='):
        manager_version = line.strip().split('=', 1)[1]
if not comfyui_version or not manager_version:
    print('::error::Could not find versions in input file')
    sys.exit(1)

# Read the Dockerfile
dockerfile_path = sys.argv[2]
with open(dockerfile_path, 'r') as f:
    dockerfile = f.read()

# Adjust regex to match COMFYUI_TAG and COMFYUI_MANAGER_TAG
comfyui_re = re.compile(r'COMFYUI_TAG=([\w\.-]+)')
manager_re = re.compile(r'COMFYUI_MANAGER_TAG=([\w\.-]+)')
current_comfyui = comfyui_re.search(dockerfile)
current_manager = manager_re.search(dockerfile)

updated = False
if current_comfyui and current_manager:
    current_comfyui_version = current_comfyui.group(1)
    current_manager_version = current_manager.group(1)
    if (version.parse(comfyui_version) != version.parse(current_comfyui_version) or
        version.parse(manager_version) != version.parse(current_manager_version)):
        # Replace versions
        dockerfile = comfyui_re.sub(f'COMFYUI_TAG={comfyui_version}', dockerfile)
        dockerfile = manager_re.sub(f'COMFYUI_MANAGER_TAG={manager_version}', dockerfile)
        with open(dockerfile_path, 'w') as f:
            f.write(dockerfile)
        updated = True
else:
    print('::error::Could not find version variables in Dockerfile')
    sys.exit(1)

# Set output for GitHub Actions
print(f"::set-output name=updated::{str(updated).lower()}")
