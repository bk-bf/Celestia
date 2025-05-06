# NameDatabase.gd
extends Node
class_name NameDatabase


var male_first_names = [
	"James", "John", "Robert", "Michael", "William",
	"David", "Richard", "Joseph", "Thomas", "Charles",
	"Liam", "Noah", "Oliver", "Elijah", "Lucas",
	"Mason", "Logan", "Ethan", "Jacob", "Matthew",
	"Benjamin", "Alexander", "Henry", "Samuel", "Daniel",
	"Jackson", "Sebastian", "Jack", "Aiden", "Owen",
	"Gabriel", "Carter", "Jayden", "John", "Luke",
	"Anthony", "Isaac", "Dylan", "Wyatt", "Andrew",
	"Joshua", "Christopher", "Grayson", "Julian", "Mateo",
	"Ryan", "Nathan", "Leo", "Aaron", "Isaiah"
]

var female_first_names = [
	"Mary", "Patricia", "Jennifer", "Linda", "Elizabeth",
	"Barbara", "Susan", "Jessica", "Sarah", "Karen",
	"Olivia", "Emma", "Charlotte", "Amelia", "Sophia",
	"Mia", "Isabella", "Ava", "Evelyn", "Luna",
	"Harper", "Camila", "Sofia", "Scarlett", "Emily",
	"Aria", "Ella", "Gianna", "Chloe", "Layla",
	"Lily", "Ellie", "Nora", "Hazel", "Zoe",
	"Victoria", "Madison", "Eleanor", "Grace", "Penelope",
	"Riley", "Zoey", "Natalie", "Hannah", "Leah",
	"Aubrey", "Stella", "Aurora", "Maya", "Abigail"
]

var surnames = [
	"Smith", "Johnson", "Williams", "Jones", "Brown",
	"Davis", "Miller", "Wilson", "Moore", "Taylor",
	"Anderson", "Thomas", "Jackson", "White", "Harris",
	"Martin", "Thompson", "Garcia", "Martinez", "Robinson",
	"Clark", "Rodriguez", "Lewis", "Lee", "Walker",
	"Hall", "Allen", "Young", "Hernandez", "King",
	"Wright", "Lopez", "Hill", "Scott", "Green",
	"Adams", "Baker", "Gonzalez", "Nelson", "Carter",
	"Mitchell", "Perez", "Roberts", "Turner", "Phillips",
	"Campbell", "Parker", "Evans", "Edwards", "Collins"
]

var pawn_gender = "male" # default gender (no offence)

func get_random_name():
    pawn_gender = "male" if randf() > 0.5 else "female" # assign random gender
    var first_name
    if pawn_gender == "male":
        first_name = male_first_names[randi() % male_first_names.size()]
    else: # pawn_gender == "female"
        first_name = female_first_names[randi() % female_first_names.size()]
    
    var surname = surnames[randi() % surnames.size()]
    return {
        "name": first_name + " " + surname,
        "gender": pawn_gender
    }
