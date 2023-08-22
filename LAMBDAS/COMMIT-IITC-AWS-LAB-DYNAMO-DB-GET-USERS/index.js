const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();
exports.handler = async (event, context, callback) => {
    try {
        const params = {
            TableName: process.env.TABLE_NAME
        }
        const data = await docClient.scan(params).promise()
        const response = {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Headers': '*',
                'Access-Control-Allow-Origin':'*'
            },
            body: JSON.stringify(data),
          };
          callback(null, response);
        }
    catch (err) {
        console.error('Error scaning the DB:', err);
        const errorResponse = {
            statusCode: 500,
            headers: {
                'Access-Control-Allow-Headers': '*',
                'Access-Control-Allow-Origin':'*'
            },
            body: JSON.stringify(err) 
        }
        callback(errorResponse , null);
    }
};