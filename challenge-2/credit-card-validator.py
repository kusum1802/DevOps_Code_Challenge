import re

num = int(input("Number of credit cards: ")) #Passing N number of credit card numbers.

for i in range(num):
    
    card_number = input() #Passing each credit card number in the given range

    pattern = re.search(r'^[4-6]\d{15}|[4-6]\d{3}-\d{4}-\d{4}-\d{4}$', card_number) #This checks the card number starting with 4,5 or 6; 16 digit count, digits in group of 4 seperated by -, and avoiding other characters whitespace,_ etc. 
    
    if(pattern):
        if(re.search(r'(\d)\1{3,}|(\d)\2{1}-(\d)\2{1}|-(\d)\4{3}-|\d{17}', card_number)): # This checks if 4 or more consecutive repeated digits are present, and if there are any card numbers with more that 16 digit count
            print("Invalid")
        else:
            print("Valid")
    else:
        print("Invalid")

