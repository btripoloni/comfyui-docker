import requests
import sys

def get_latest_tag(repo):
    url = f"https://api.github.com/repos/{repo}/tags"
    r = requests.get(url, timeout=10)
    r.raise_for_status()
    tags = r.json()
    if not tags:
        print(f"No tags found for {repo}", file=sys.stderr)
        sys.exit(1)
    return tags[0]['name']

if __name__ == "__main__":
    comfyui_repo = "comfyanonymous/ComfyUI"
    manager_repo = "ltdrdata/ComfyUI-Manager"
    comfyui_version = get_latest_tag(comfyui_repo)
    manager_version = get_latest_tag(manager_repo)
    print(f"COMFYUI_VERSION={comfyui_version}")
    print(f"MANAGER_VERSION={manager_version}")
