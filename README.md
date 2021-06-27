# Algorithm for pseudo-randomly picking a winner from a CSV file

The algorithm goes like this:

1. Hash the input file with SHA256
2. Seed a pseudo RNG with the first 40 bytes of the hash
3. Generate the winner index between 0 and the max number of rows in the input file
4. Print the winner name and email

