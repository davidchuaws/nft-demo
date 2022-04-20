from brownie import AdvancedCollectible, network
from requests import request
from scripts.helpful_scripts import get_animal
from metadata.sample_metadata import metadata_template
from pathlib import Path
import requests, json, os

animal_to_image_uri = {

}

def main():
    advanced_collectible = AdvancedCollectible[-1]
    number_of_advanced_collectibles = advanced_collectible.tokenCounter()
    print(f"You have created {number_of_advanced_collectibles} collectibles!")
    for token_id in range(number_of_advanced_collectibles):
        animal = get_animal(advanced_collectible.tokenIdToAnimal(token_id))
        metadata_file_name = (
            f"./metadata/{network.show_active()}/{token_id}-{animal}.json"
        )
        collectible_metadata = metadata_template
        if Path(metadata_file_name).exists():
            print(f"{metadata_file_name} already exists! Delete to overwrite!")
        else:
            print(f"Creating metadata file: {metadata_file_name}")
            collectible_metadata["name"] = animal
            collectible_metadata["description"] = f"An adorable {animal}!"
            image_path= "./img/" + animal.lower().replace("_", "-") + ".png"
            if os.getenv("UPLOAD_IPFS")=="true":
                image_uri = upload_to_ipfs(image_path)
            image_uri = image_uri if image_uri else animal_to_image_uri[animal]
            collectible_metadata["image"] = image_uri
            with open(metadata_file_name, "w") as file:
                json.dump(collectible_metadata, file)
            if os.getenv("UPLOAD_IPFS") == "true":
                upload_to_ipfs(metadata_file_name)

def upload_to_ipfs(filepath):
    with Path(filepath).open("rb") as fp:
        image_binary = fp.read()
        ipfs_url = "http://127.0.0.1:5001"
        endpoint = "/api/v0/add"
        response = requests.post(ipfs_url + endpoint, files={"file":image_binary})
        ipfs_hash = response.json()["Hash"]
        # "/.img/0-PUG.png" -> "0-PUG.png"
        filename = filepath.split("/")[-1:][0]
        image_uri = f"https://ipfs.io/ipfs/{ipfs_hash}?filename={filename}"
        print(image_uri)
        return image_uri