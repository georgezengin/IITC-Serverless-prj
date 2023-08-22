const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();
const s3Client = new AWS.S3();
const ssm = new AWS.SSM();
const ddb = new AWS.DynamoDB();

exports.handler = async (event, context, callback) => {
    console.log("************" , event , "************" );
    try {
        const data = await docClient.get({
            TableName: process.env.TABLE_NAME,
            Key: {
                email: event.requestContext.authorizer.claims.email
            }
        }).promise()
        const inputUserToS3BucketResponse = await s3Client.putObject({
            Bucket: process.env.BUCKET,
            Key: `${data.Item.name}.txt`,
            Body: new Date().toISOString(),
        }).promise()
    }
    catch (err) {
        console.error('Error wrting new file:', err);
        const errorResponse = {
          statusCode: 500,
          headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Headers': '*',
              'Access-Control-Allow-Origin':'*'
          },
          body: JSON.stringify(err)
        }
        callback(errorResponse , null);
    }
    try {
        const userData = await docClient.get({
            TableName: process.env.TABLE_NAME,
            Key: {
                email: event.requestContext.authorizer.claims.email
            }
        }).promise()
        const parameterName = process.env.USER_MESSAGE;
        const params = {
          Name: parameterName,
          WithDecryption: false // Set this to true if the parameter is encrypted
        };
        const data = await ssm.getParameter(params).promise();
        const parameterValue = data.Parameter.Value;
        const nameOftheUser = userData.Item.name
        const response = {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Headers': '*',
                'Access-Control-Allow-Origin':'*'
            },
            body: JSON.stringify(`${parameterValue} : ${nameOftheUser}!`)
          };
        callback(null , response);
    } catch (err) {
        console.error('Error retrieving parameter:', err);
        const errorResponse = {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Headers': '*',
                'Access-Control-Allow-Origin':'*'
            },
            body: JSON.stringify('Error retrieving parameter from Parameter Store')
        }
        callback(errorResponse, null)
    }
};