"""
Seed script: create 12 users, download real pet images, post 3 pets per user.
Run with: python seed_users_pets.py
"""

import requests
import json
import os
import random
import time

BASE_URL = "http://127.0.0.1:8000/api"
IMG_DIR = "/tmp/pet_seed_images"
os.makedirs(IMG_DIR, exist_ok=True)

# ── 12 users ──────────────────────────────────────────────────────────────────
USERS = [
    {"username": "alice_pet",    "password": "Alice@1234",   "email": "alice@petapp.com",    "first_name": "Alice",   "last_name": "Walker"},
    {"username": "bob_furry",    "password": "Bob@1234",     "email": "bob@petapp.com",      "first_name": "Bob",     "last_name": "Smith"},
    {"username": "carol_paws",   "password": "Carol@1234",   "email": "carol@petapp.com",    "first_name": "Carol",   "last_name": "Jones"},
    {"username": "david_woof",   "password": "David@1234",   "email": "david@petapp.com",    "first_name": "David",   "last_name": "Brown"},
    {"username": "emma_whisker", "password": "Emma@1234",    "email": "emma@petapp.com",     "first_name": "Emma",    "last_name": "Wilson"},
    {"username": "frank_tail",   "password": "Frank@1234",   "email": "frank@petapp.com",    "first_name": "Frank",   "last_name": "Davis"},
    {"username": "grace_kitty",  "password": "Grace@1234",   "email": "grace@petapp.com",    "first_name": "Grace",   "last_name": "Miller"},
    {"username": "henry_bark",   "password": "Henry@1234",   "email": "henry@petapp.com",    "first_name": "Henry",   "last_name": "Taylor"},
    {"username": "iris_bunny",   "password": "Iris@1234",    "email": "iris@petapp.com",     "first_name": "Iris",    "last_name": "Anderson"},
    {"username": "jack_feather", "password": "Jack@1234",    "email": "jack@petapp.com",     "first_name": "Jack",    "last_name": "Thomas"},
    {"username": "karen_fin",    "password": "Karen@1234",   "email": "karen@petapp.com",    "first_name": "Karen",   "last_name": "Jackson"},
    {"username": "leo_hamster",  "password": "Leo@1234",     "email": "leo@petapp.com",      "first_name": "Leo",     "last_name": "White"},
]

# ── Pet data (3 per user, spread across all 6 categories) ─────────────────────
# category ids: Dog=1, Cat=2, Bird=3, Rabbit=4, Fish=5, Hamster=6
PETS_PER_USER = [
    # alice_pet
    [
        {"name": "Max",     "category": 1, "breed": "Golden Retriever", "age_years": 2, "gender": "male",   "size": "large",  "color": "Golden",      "description": "Friendly and energetic golden retriever who loves fetch.", "is_vaccinated": True,  "is_neutered": True,  "activity_level": "high",   "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Whiskers","category": 2, "breed": "Persian",          "age_years": 3, "gender": "female", "size": "medium", "color": "White",       "description": "Calm and fluffy Persian cat, loves cuddles.",              "is_vaccinated": True,  "is_neutered": True,  "activity_level": "low",    "good_with_children": True,  "good_with_other_pets": False},
        {"name": "Tweety",  "category": 3, "breed": "Canary",           "age_years": 1, "gender": "male",   "size": "small",  "color": "Yellow",      "description": "Cheerful canary with a beautiful singing voice.",          "is_vaccinated": False, "is_neutered": False, "activity_level": "medium", "good_with_children": True,  "good_with_other_pets": True},
    ],
    # bob_furry
    [
        {"name": "Bella",   "category": 1, "breed": "Labrador",         "age_years": 1, "gender": "female", "size": "large",  "color": "Black",       "description": "Playful lab puppy, great with kids.",                     "is_vaccinated": True,  "is_neutered": False, "activity_level": "high",   "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Shadow",  "category": 2, "breed": "British Shorthair","age_years": 4, "gender": "male",   "size": "medium", "color": "Grey",        "description": "Cool and composed shorthair, loves sunny spots.",          "is_vaccinated": True,  "is_neutered": True,  "activity_level": "low",    "good_with_children": False, "good_with_other_pets": False},
        {"name": "Snowball","category": 4, "breed": "Holland Lop",      "age_years": 2, "gender": "female", "size": "small",  "color": "White",       "description": "Adorable lop-eared rabbit, very gentle.",                 "is_vaccinated": True,  "is_neutered": True,  "activity_level": "low",    "good_with_children": True,  "good_with_other_pets": True},
    ],
    # carol_paws
    [
        {"name": "Rocky",   "category": 1, "breed": "German Shepherd",  "age_years": 3, "gender": "male",   "size": "large",  "color": "Brown/Black", "description": "Loyal and intelligent shepherd, well trained.",            "is_vaccinated": True,  "is_neutered": True,  "activity_level": "high",   "good_with_children": True,  "good_with_other_pets": False},
        {"name": "Luna",    "category": 2, "breed": "Siamese",          "age_years": 2, "gender": "female", "size": "medium", "color": "Cream/Brown", "description": "Talkative Siamese who loves attention.",                  "is_vaccinated": True,  "is_neutered": True,  "activity_level": "medium", "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Nemo",    "category": 5, "breed": "Clownfish",        "age_years": 1, "gender": "unknown","size": "small",  "color": "Orange/White","description": "Vibrant clownfish perfect for a home aquarium.",           "is_vaccinated": False, "is_neutered": False, "activity_level": "low",    "good_with_children": True,  "good_with_other_pets": True},
    ],
    # david_woof
    [
        {"name": "Cooper",  "category": 1, "breed": "Beagle",           "age_years": 2, "gender": "male",   "size": "medium", "color": "Tricolor",    "description": "Curious beagle always sniffing out adventures.",          "is_vaccinated": True,  "is_neutered": True,  "activity_level": "high",   "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Mittens", "category": 2, "breed": "Maine Coon",       "age_years": 5, "gender": "female", "size": "large",  "color": "Tabby",       "description": "Giant Maine Coon, gentle giant with silky fur.",           "is_vaccinated": True,  "is_neutered": True,  "activity_level": "medium", "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Hoppy",   "category": 4, "breed": "Flemish Giant",    "age_years": 1, "gender": "male",   "size": "large",  "color": "Grey",        "description": "Giant rabbit breed, surprisingly calm and cuddly.",       "is_vaccinated": True,  "is_neutered": False, "activity_level": "low",    "good_with_children": True,  "good_with_other_pets": True},
    ],
    # emma_whisker
    [
        {"name": "Daisy",   "category": 1, "breed": "Poodle",           "age_years": 3, "gender": "female", "size": "small",  "color": "White",       "description": "Intelligent mini poodle, hypoallergenic and sweet.",       "is_vaccinated": True,  "is_neutered": True,  "activity_level": "medium", "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Oscar",   "category": 2, "breed": "Ragdoll",          "age_years": 2, "gender": "male",   "size": "large",  "color": "Blue/White",  "description": "Floppy ragdoll cat, goes limp when held—so lovable.",     "is_vaccinated": True,  "is_neutered": True,  "activity_level": "low",    "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Kiwi",    "category": 3, "breed": "Budgerigar",       "age_years": 1, "gender": "male",   "size": "small",  "color": "Green/Yellow","description": "Chatty budgie who can mimic words.",                      "is_vaccinated": False, "is_neutered": False, "activity_level": "medium", "good_with_children": True,  "good_with_other_pets": True},
    ],
    # frank_tail
    [
        {"name": "Duke",    "category": 1, "breed": "Rottweiler",       "age_years": 4, "gender": "male",   "size": "large",  "color": "Black/Tan",   "description": "Well-trained Rottweiler, calm and protective.",            "is_vaccinated": True,  "is_neutered": True,  "activity_level": "medium", "good_with_children": False, "good_with_other_pets": False},
        {"name": "Cleo",    "category": 2, "breed": "Abyssinian",       "age_years": 3, "gender": "female", "size": "medium", "color": "Ruddy",       "description": "Active Abyssinian, loves to climb and explore.",          "is_vaccinated": True,  "is_neutered": True,  "activity_level": "high",   "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Goldie",  "category": 5, "breed": "Goldfish",         "age_years": 2, "gender": "unknown","size": "small",  "color": "Orange",      "description": "Classic orange goldfish, serene and beautiful.",           "is_vaccinated": False, "is_neutered": False, "activity_level": "low",    "good_with_children": True,  "good_with_other_pets": True},
    ],
    # grace_kitty
    [
        {"name": "Buddy",   "category": 1, "breed": "Boxer",            "age_years": 2, "gender": "male",   "size": "large",  "color": "Fawn",        "description": "Energetic boxer who loves to play and cuddle.",            "is_vaccinated": True,  "is_neutered": True,  "activity_level": "high",   "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Nala",    "category": 2, "breed": "Bengal",           "age_years": 1, "gender": "female", "size": "medium", "color": "Spotted",     "description": "Wild-looking Bengal with a playful personality.",          "is_vaccinated": True,  "is_neutered": False, "activity_level": "high",   "good_with_children": False, "good_with_other_pets": False},
        {"name": "Nibbles", "category": 6, "breed": "Syrian Hamster",   "age_years": 1, "gender": "male",   "size": "small",  "color": "Golden",      "description": "Friendly Syrian hamster, loves running on his wheel.",    "is_vaccinated": False, "is_neutered": False, "activity_level": "medium", "good_with_children": True,  "good_with_other_pets": False},
    ],
    # henry_bark
    [
        {"name": "Zeus",    "category": 1, "breed": "Husky",            "age_years": 3, "gender": "male",   "size": "large",  "color": "Grey/White",  "description": "Stunning husky with striking blue eyes, loves cold weather.", "is_vaccinated": True, "is_neutered": True,  "activity_level": "high",   "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Pixel",   "category": 2, "breed": "Sphynx",           "age_years": 2, "gender": "male",   "size": "medium", "color": "Skin-toned",  "description": "Hairless sphynx cat, warm and affectionate.",             "is_vaccinated": True,  "is_neutered": True,  "activity_level": "medium", "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Mango",   "category": 3, "breed": "Cockatiel",        "age_years": 2, "gender": "male",   "size": "small",  "color": "Yellow/Grey", "description": "Sweet cockatiel who loves to whistle tunes.",             "is_vaccinated": False, "is_neutered": False, "activity_level": "medium", "good_with_children": True,  "good_with_other_pets": True},
    ],
    # iris_bunny
    [
        {"name": "Rosie",   "category": 1, "breed": "Cavalier King Charles", "age_years": 2, "gender": "female", "size": "small",  "color": "Chestnut/White", "description": "Sweet spaniel, perfect lap dog.",              "is_vaccinated": True,  "is_neutered": True,  "activity_level": "medium", "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Pumpkin", "category": 4, "breed": "Mini Rex",         "age_years": 1, "gender": "female", "size": "small",  "color": "Orange",      "description": "Velvet-soft mini rex rabbit, loves to hop around.",       "is_vaccinated": True,  "is_neutered": True,  "activity_level": "medium", "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Zigzag",  "category": 6, "breed": "Dwarf Hamster",    "age_years": 1, "gender": "female", "size": "small",  "color": "Grey/White",  "description": "Tiny dwarf hamster, super fast and fun to watch.",        "is_vaccinated": False, "is_neutered": False, "activity_level": "high",   "good_with_children": False, "good_with_other_pets": False},
    ],
    # jack_feather
    [
        {"name": "Ace",     "category": 1, "breed": "Dalmatian",        "age_years": 2, "gender": "male",   "size": "large",  "color": "White/Black", "description": "Spotted Dalmatian, full of energy and spots.",             "is_vaccinated": True,  "is_neutered": True,  "activity_level": "high",   "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Loki",    "category": 2, "breed": "Norwegian Forest", "age_years": 3, "gender": "male",   "size": "large",  "color": "Tabby/White", "description": "Majestic Norwegian forest cat, loves being outdoors.",    "is_vaccinated": True,  "is_neutered": True,  "activity_level": "medium", "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Sunny",   "category": 3, "breed": "Lovebird",         "age_years": 1, "gender": "female", "size": "small",  "color": "Green/Red",   "description": "Affectionate lovebird, bonds strongly with owners.",      "is_vaccinated": False, "is_neutered": False, "activity_level": "medium", "good_with_children": True,  "good_with_other_pets": True},
    ],
    # karen_fin
    [
        {"name": "Pepper",  "category": 1, "breed": "Cocker Spaniel",   "age_years": 4, "gender": "female", "size": "medium", "color": "Brown",       "description": "Gentle cocker spaniel with long silky ears.",             "is_vaccinated": True,  "is_neutered": True,  "activity_level": "medium", "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Dory",    "category": 5, "breed": "Blue Tang",        "age_years": 1, "gender": "female", "size": "small",  "color": "Blue/Yellow", "description": "Vibrant blue tang, keeps the aquarium lively.",           "is_vaccinated": False, "is_neutered": False, "activity_level": "medium", "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Biscuit", "category": 4, "breed": "Angora",           "age_years": 2, "gender": "male",   "size": "medium", "color": "White",       "description": "Fluffy angora rabbit, looks like a cloud.",               "is_vaccinated": True,  "is_neutered": True,  "activity_level": "low",    "good_with_children": True,  "good_with_other_pets": True},
    ],
    # leo_hamster
    [
        {"name": "Thor",    "category": 1, "breed": "Samoyed",          "age_years": 1, "gender": "male",   "size": "large",  "color": "White",       "description": "Fluffy white Samoyed, always smiling and friendly.",      "is_vaccinated": True,  "is_neutered": False, "activity_level": "high",   "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Caramel", "category": 2, "breed": "Scottish Fold",    "age_years": 2, "gender": "female", "size": "medium", "color": "Orange",      "description": "Adorable folded-ear cat with a sweet temperament.",       "is_vaccinated": True,  "is_neutered": True,  "activity_level": "low",    "good_with_children": True,  "good_with_other_pets": True},
        {"name": "Peanut",  "category": 6, "breed": "Roborovski Hamster","age_years": 1, "gender": "male",  "size": "small",  "color": "Sandy",       "description": "World's smallest hamster, incredibly fast and cute.",     "is_vaccinated": False, "is_neutered": False, "activity_level": "high",   "good_with_children": False, "good_with_other_pets": False},
    ],
]

# ── Image sources per category ─────────────────────────────────────────────────
# Using public free-to-use image URLs grouped by category
IMAGE_URLS = {
    1: [  # Dogs
        "https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/YellowLabradorLooking_new.jpg/1200px-YellowLabradorLooking_new.jpg",
        "https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Dog_Breeds.jpg/1200px-Dog_Breeds.jpg",
        "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Collage_of_Nine_Dogs.jpg/1200px-Collage_of_Nine_Dogs.jpg",
        "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Camponotus_flavomarginatus_ant.jpg/320px-Camponotus_flavomarginatus_ant.jpg",
        "https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400",
        "https://images.unsplash.com/photo-1552053831-71594a27632d?w=400",
        "https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?w=400",
    ],
    2: [  # Cats
        "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400",
        "https://images.unsplash.com/photo-1573865526739-10659fec78a5?w=400",
        "https://images.unsplash.com/photo-1495360010541-f48722b34f7d?w=400",
        "https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400",
        "https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=400",
        "https://images.unsplash.com/photo-1536590158209-e9d615d525e4?w=400",
    ],
    3: [  # Birds
        "https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=400",
        "https://images.unsplash.com/photo-1444464666168-49d633b86797?w=400",
        "https://images.unsplash.com/photo-1606567595334-d39972c85dbe?w=400",
        "https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=400",
    ],
    4: [  # Rabbits
        "https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=400",
        "https://images.unsplash.com/photo-1573227896778-3e8d7df5b2ae?w=400",
        "https://images.unsplash.com/photo-1535241749838-299277b6305f?w=400",
        "https://images.unsplash.com/photo-1608848461950-0fe51dfc41cb?w=400",
    ],
    5: [  # Fish
        "https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?w=400",
        "https://images.unsplash.com/photo-1535591273668-578e31182c4f?w=400",
        "https://images.unsplash.com/photo-1548248823-ce16a73b6d49?w=400",
    ],
    6: [  # Hamsters
        "https://images.unsplash.com/photo-1425082661705-1834bfd09dca?w=400",
        "https://images.unsplash.com/photo-1548767797-d8c844163c4a?w=400",
        "https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=400",
    ],
}

# ── Download helper ────────────────────────────────────────────────────────────
_img_counters = {}

def download_image(category_id, pet_name):
    urls = IMAGE_URLS.get(category_id, IMAGE_URLS[1])
    idx = _img_counters.get(category_id, 0) % len(urls)
    _img_counters[category_id] = idx + 1
    url = urls[idx]
    filename = f"{IMG_DIR}/{pet_name.lower().replace(' ','_')}_cat{category_id}_{idx}.jpg"
    if os.path.exists(filename):
        return filename
    try:
        headers = {"User-Agent": "Mozilla/5.0 (PetSeedScript/1.0)"}
        r = requests.get(url, headers=headers, timeout=15)
        if r.status_code == 200:
            with open(filename, "wb") as f:
                f.write(r.content)
            return filename
    except Exception as e:
        print(f"    [warn] image download failed for {pet_name}: {e}")
    return None

# ── API helpers ────────────────────────────────────────────────────────────────
def register(user):
    r = requests.post(f"{BASE_URL}/auth/register/", json={
        "username": user["username"],
        "password": user["password"],
        "password2": user["password"],
        "email": user["email"],
        "first_name": user["first_name"],
        "last_name": user["last_name"],
    })
    return r.status_code in (200, 201), r.text

def login(username, password):
    r = requests.post(f"{BASE_URL}/auth/login/", json={"username": username, "password": password})
    if r.status_code == 200:
        return r.json()["access"]
    return None

def post_pet(token, pet, image_path):
    headers = {"Authorization": f"Bearer {token}"}
    fields = {k: str(v) for k, v in pet.items()}
    # Convert booleans to lowercase strings
    for k in ("is_vaccinated", "is_neutered", "is_microchipped", "good_with_children", "good_with_other_pets"):
        if k in fields:
            fields[k] = fields[k].lower()

    if image_path and os.path.exists(image_path):
        with open(image_path, "rb") as f:
            files = {"primary_image": (os.path.basename(image_path), f, "image/jpeg")}
            r = requests.post(f"{BASE_URL}/pets/", headers=headers, data=fields, files=files)
    else:
        r = requests.post(f"{BASE_URL}/pets/", headers=headers, data=fields)
    return r.status_code in (200, 201), r.text

# ── Main ───────────────────────────────────────────────────────────────────────
def main():
    results = []
    print(f"{'='*60}")
    print("Pet Adoption Seed Script")
    print(f"{'='*60}\n")

    for i, user in enumerate(USERS):
        print(f"[{i+1:02d}/12] {user['username']}")

        # Register
        ok, resp = register(user)
        if ok:
            print(f"       ✓ Registered")
        else:
            # May already exist
            if "already" in resp.lower() or "unique" in resp.lower() or "exists" in resp.lower():
                print(f"       ~ Already exists, continuing...")
            else:
                print(f"       ✗ Register failed: {resp}")

        # Login
        token = login(user["username"], user["password"])
        if not token:
            print(f"       ✗ Login failed, skipping pets")
            results.append({**user, "pets_posted": 0})
            continue
        print(f"       ✓ Logged in")

        # Post 3 pets
        pets_posted = 0
        for pet in PETS_PER_USER[i]:
            img = download_image(pet["category"], pet["name"])
            ok, resp = post_pet(token, pet, img)
            status = "✓" if ok else "✗"
            print(f"       {status} Pet: {pet['name']} ({['','Dog','Cat','Bird','Rabbit','Fish','Hamster'][pet['category']]}){' - ' + resp[:80] if not ok else ''}")
            if ok:
                pets_posted += 1
            time.sleep(0.3)

        results.append({**user, "pets_posted": pets_posted})
        print()

    # Write users.txt
    txt_path = "/run/media/dheena/Leave you files/pet/users.txt"
    with open(txt_path, "w") as f:
        f.write("Pet Adoption App - User Accounts\n")
        f.write("=" * 50 + "\n\n")
        for r in results:
            f.write(f"Username : {r['username']}\n")
            f.write(f"Password : {r['password']}\n")
            f.write(f"Email    : {r['email']}\n")
            f.write(f"Name     : {r['first_name']} {r['last_name']}\n")
            f.write(f"Pets     : {r['pets_posted']}/3 posted\n")
            f.write("-" * 50 + "\n")

    print(f"\n{'='*60}")
    print(f"Done! Credentials saved to: {txt_path}")
    total_pets = sum(r['pets_posted'] for r in results)
    print(f"Total users: {len(results)}  |  Total pets posted: {total_pets}")

if __name__ == "__main__":
    main()
