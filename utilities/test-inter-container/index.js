const axios = require('axios').default
const https = require('https')

/* Determines if successful from the HTTP response code */
const getResponseType = (code) => {
  if (Number.isNaN(code)) return false
  const numericCode = parseInt(code, 10)
  return numericCode >= 200 && numericCode <= 302
}

/* Makes human-readable response text for successful check */
const makeMessageText = (data) =>
  `${data.successStatus ? '✅' : '⚠️'} ` +
  `${data.serverName || 'Server'} responded with ` +
  `${data.statusCode} - ${data.statusText}. ` +
  `\n⏱️Took ${data.timeTaken} ms`

/* Makes human-readable response text for failed check */
const makeErrorMessage = (data) =>
  `❌ Service Unavailable: ${data.hostname || 'Server'} ` +
  `resulted in ${data.code || 'a fatal error'} ${
    data.errno ? `(${data.errno})` : ''
  }`

const makeErrorMessage2 = (data) =>
  '❌ Service Error - ' + `${data.status} - ${data.statusText}`

/* Kicks of a HTTP request, then formats and renders results */
const makeRequest = (url, headers, insecure, render) => {
  const startTime = new Date()
  const requestMaker = axios.create({
    httpsAgent: new https.Agent({
      rejectUnauthorized: !insecure,
    }),
  })
  requestMaker
    .get(url, { headers })
    .then((response) => {
      const statusCode = response.status
      const { statusText } = response
      const successStatus = getResponseType(statusCode)
      const serverName = response.request.socket.servername
      const timeTaken = new Date() - startTime
      const results = {
        statusCode,
        statusText,
        serverName,
        successStatus,
        timeTaken,
      }
      const messageText = makeMessageText(results)
      results.message = messageText
      return results
    })
    .catch((error) => {
      console.log('ERROR', error)
      render(
        JSON.stringify({
          successStatus: false,
          message: error.response
            ? makeErrorMessage2(error.response)
            : makeErrorMessage(error),
        })
      )
    })
    .then((results) => {
      render(JSON.stringify(results))
    })
}

// makeRequest('http://expenses.picco.li/', undefined, true, (a) =>
//   console.log('RENDER', a)
// )

makeRequest('https://google.com/', undefined, true, (a) =>
  console.log('RENDER', a)
)
