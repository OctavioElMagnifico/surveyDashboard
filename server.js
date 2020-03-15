const express = require('express')
const { exec } = require('child_process');
const bodyParser = require('body-parser')
const asyncHandler = require('express-async-handler')

const PORT = process.env.PORT || 4040

const app = express()
app.use(bodyParser.json())

const execRscript = async (script, args, output) => {
  return new Promise((resolve, reject) => {
    const command = `$Rscript {__dirname}/rscript/${script} ${args.map(arg => `"${arg}"`).join(' ')}`
    const outputPath = `${__dirname}/output/${output}`
    exec(command, {env: { OUTPUT_FILE: outputPath} } ,(err, stdout, stderr) => {
      if(err) {
        reject(err)
      }
      resolve({ stdout, stderr, outputPath })
    })
  })
}

app.get('/pages/:page', (req, res) => {
  const pageName = req.params.page
  res.sendFile(`${__dirname}/pages/${pageName}.html`)
})

app.post('/rexec', asyncHandler(async (req, res) => {
  const { script, arguments: args, output } = req.body
  const {
    stdout,
    stderr
  } = await execRscript(script, args, output)
  res.send({
    stdout,
    stderr
  })
}))

app.post('/rexec/csv', asyncHandler(async (req, res) => {
  const { script, arguments: args, output } = req.body
  const {
    outputPath
  } = await execRscript(script, args, output)
  res.setHeader('Content-Type', 'text/csv')
  res.sendFile(outputPath)
}))

app.get('/csv/:name', (req, res) => {
  const csvName = req.params.name
  res.setHeader('Content-Type', 'text/csv')
  res.sendFile(`${__dirname}/output/${csvName}`)
})

app.get('/rds/:name', (req, res) => {
  const rdsName = req.params.name
  res.sendFile(`${__dirname}/dataAnalysis/${rdsName}`)
})

app.get('/json/:name', (req, res) => {
  const jsonName = req.params.name
  res.setHeader('Content-Type', 'text/json')
  res.sendFile(`${__dirname}/output/${jsonName}`)
})

app.listen(PORT, () => console.log(`Server ready on port ${PORT}`))
