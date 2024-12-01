import express from 'express';

const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.send('<h1>Hello Express World!</h1>');
});

app.get('/api/v2/rocket-man1/', (req, res) => {
    const myobject = { who: "rocket man", where: "mars" };
    res.json(myobject);
})

app.listen(port, () => {
    console.log(`Server running at http://localhost:${ port }`);
});
