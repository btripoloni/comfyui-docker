import requests
import sys

def get_latest_tag(repo):
    url = f"https://api.github.com/repos/{repo}/tags"
    try:
        r = requests.get(url, timeout=10)
        r.raise_for_status()
        tags = r.json()
        if not tags:
            raise ValueError(f"No tags found for {repo}")
        return tags[0]['name']
    except Exception as e:
        print(f"Error fetching tags for {repo}: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    comfyui_repo = "Comfy-Org/ComfyUI"
    manager_repo = "Comfy-Org/ComfyUI-Manager"
    comfyui_version = get_latest_tag(comfyui_repo)
    manager_version = get_latest_tag(manager_repo)
    print(f"COMFYUI_VERSION={comfyui_version}")
    print(f"MANAGER_VERSION={manager_version}")
