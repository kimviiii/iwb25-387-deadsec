# Setting up MongoDB Atlas for VoluntHere

## Connection Information

You have provided the following MongoDB Atlas credentials:

- **Username**: kalanakivindu22
- **Password**: MBN6lcl6cmw8LqA2
- **Cluster**: cluster0

## Steps to Connect VoluntHere to MongoDB Atlas

1. **Create a MongoDB Atlas Account**
   - If you haven't already, sign up at https://www.mongodb.com/cloud/atlas/register

2. **Set Up Your Cluster**
   - You already have "cluster0" set up.

3. **Configure Network Access**
   - Go to Network Access in the Security section
   - Click "Add IP Address"
   - Choose "Allow Access from Anywhere" (for development purposes)
   - Or add your specific IP address for better security

4. **Set Up Database Access**
   - Ensure your username and password are working

5. **Get Your Connection String**
   - Go to Clusters > Connect > Connect your application
   - Copy the connection string which looks like:
     `mongodb+srv://kalanakivindu22:MBN6lcl6cmw8LqA2@cluster0.mongodb.net/?retryWrites=true&w=majority`

6. **Create Your Database and Collections**
   - Create a database named "volunthere"
   - Create collections: "events", "volunteers", and "rsvps"

## Integration with Ballerina

To properly integrate MongoDB with Ballerina, you'll need to:

1. Add the MongoDB module as a dependency using `bal add mongodb`
2. Create proper repository implementations using the MongoDB client
3. Configure connection strings and authentication

Since the current implementation is working with in-memory repositories, you can continue using that for now and gradually add the MongoDB integration when you're ready to deploy.
