const express = require('express');
const { exec } = require('child_process');
const stripAnsi = require('strip-ansi').default;

const app = express();
const port = 3000;

// Terraform Init
app.get('/terraform/init', (req, res) => {
    exec('terraform init', { cwd: './terraform' }, (err, stdout, stderr) => {
        if (err) return res.status(500).send(`<pre>${stripAnsi(stderr || err.message)}</pre>`);
        res.send(`<pre>${stripAnsi(stdout)}</pre>`);
    });
});

// Terraform Apply
app.get('/terraform/apply', (req, res) => {
    exec('terraform apply -auto-approve', { cwd: './terraform' }, (err, stdout, stderr) => {
        if (err) return res.status(500).send(`<pre>${stripAnsi(stderr || err.message)}</pre>`);
        res.send(`<pre>${stripAnsi(stdout)}</pre>`);
    });
});

// Terraform Destroy
app.get('/terraform/destroy', (req, res) => {
    exec('terraform destroy -auto-approve', { cwd: './terraform' }, (err, stdout, stderr) => {
        if (err) return res.status(500).send(`<pre>${stripAnsi(stderr || err.message)}</pre>`);
        res.send(`<pre>${stripAnsi(stdout)}</pre>`);
    });
});

app.listen(port, () => {
    console.log(`Server listening at http://localhost:${port}`);
});
