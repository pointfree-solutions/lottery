# Lottery for picking random picking a winner from a CSV file

The algorithm goes like this:

1. Hash the input file with SHA256
2. Seed a pseudo RNG with the first 40 bytes of the hash
3. Generate the winner index between 0 and the max number of rows in the input file
4. Print the winner name and email

See example.csv for an example of the input

Note: This was used for picking a winner for an ebook prize at Cluj FP meetup https://www.meetup.com/Cluj-fp