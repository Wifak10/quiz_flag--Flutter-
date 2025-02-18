const express = require('express');
const bodyParser = require('body-parser');
const routes = require('./routes');
require('dotenv').config();
const app = express();

app.use(bodyParser.json());
app.use('/api',routes);

const PORT = process.env.PORT || 5000;
app.listen(PORT,()=>{
console.log(`Serveur démarré sur le port ${PORT}`);

});