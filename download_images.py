import os
import requests
from bs4 import BeautifulSoup
import re

def clean_filename(name):
    return re.sub(r'[^a-z0-9-]', '', name.lower().replace(' ', '-'))

def download_image(url, filename):
    try:
        response = requests.get(url)
        if response.status_code == 200:
            with open(filename, 'wb') as f:
                f.write(response.content)
            return True
    except Exception as e:
        print(f"Error downloading {url}: {e}")
    return False

def main():
    # Create directories if they don't exist
    asset_dir = "Forest Fest/Assets.xcassets/Artists.spriteatlas"
    os.makedirs(asset_dir, exist_ok=True)

    # URL of the lineup page
    url = "https://forestfest.ie/main-lineup/"
    
    try:
        response = requests.get(url)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Find all images that contain "Forest Fest" in their alt text or src
        images = soup.find_all('img', alt=lambda x: x and 'Forest Fest' in x)
        
        for img in images:
            if img.get('src'):
                artist_name = img.get('alt', '').split('Forest Fest')[0].strip()
                if artist_name:
                    # Clean the filename
                    clean_name = clean_filename(artist_name)
                    
                    # Create image set directory
                    imageset_dir = f"{asset_dir}/{clean_name}.imageset"
                    os.makedirs(imageset_dir, exist_ok=True)
                    
                    # Download the image
                    image_path = f"{imageset_dir}/universal.jpg"
                    if download_image(img['src'], image_path):
                        # Create Contents.json for the image
                        contents_json = {
                            "images": [
                                {
                                    "filename": "universal.jpg",
                                    "idiom": "universal",
                                    "scale": "1x"
                                }
                            ],
                            "info": {
                                "author": "xcode",
                                "version": 1
                            }
                        }
                        
                        # Write Contents.json
                        import json
                        with open(f"{imageset_dir}/Contents.json", 'w') as f:
                            json.dump(contents_json, f, indent=2)
                            
                        print(f"Downloaded image for {artist_name}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main() 