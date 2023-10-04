from flask import Flask, request, render_template
import subprocess
import requests
from bs4 import BeautifulSoup
import re
import base64
import sys

app = Flask(__name__)

current_stream = None
port = '5946'


def find_available_streams():
    url = 'https://1stream.eu/'

    response = requests.get(url)

    if response.status_code == 200:
        soup = BeautifulSoup(response.content, 'html.parser')

        elements = soup.select(
            'body > div > div > div > div:nth-of-type(1) [href]')

        result = {}

        for element in elements:
            href = element['href']
            media_heading = element.select_one('.media-heading').text.strip()
            result[media_heading] = href
        return result
    else:
        print('Error: Failed to retrieve the webpage.', file=sys.stderr)


def get_stream_url(url):
    # Extract the event_id at the end of the URL using regular expressions
    match = re.search(r'(\d+)$', url)
    if match:
        event_id = match.group(1)
        # Construct the POST URL with the extracted event_id
        post_url = f'https://1stream.eu/getspurcename?{event_id}'
        # We need these to not get 403s
        headers = {
            'Referer': 'https://1stream.eu',
            'Origin': 'https://1stream.eu'
        }

        # Also needed to get a good response
        data = {
            'eventId': event_id
        }

        response = requests.post(post_url, headers=headers, data=data)

        if response.status_code == 200:
            result = response.json()
            source_value = result.get('source')
            # They return a baseURL, but it's not really necessary because the source comes with a full URL
            base_url = result.get('baseurl')
            print('Base URL' + base_url, file=sys.stderr)
            print('Source value' + source_value, file=sys.stderr)
            if source_value:
                # Source is encoded in base 64
                decoded_value = base64.b64decode(source_value).decode('utf-8')
                print(f"Decoded value: {decoded_value}", file=sys.stderr)
                return decoded_value
            else:
                print("No 'source' key found in the response.", file=sys.stderr)
        else:
            print(
                f"POST request failed with status code: {response.status_code}", file=sys.stderr)
    else:
        print("No digits found at the end of the URL.", file=sys.stderr)


def start_streamlink_stream(url):
    global current_stream
    try:

        if (current_stream):
            current_stream.terminate()
            current_stream.wait()
            current_stream.kill()

        # Create the Streamlink HLS server
        current_stream = subprocess.Popen(
            # Super important to pass the headers otherwise it'll fail
            ['streamlink', url, 'best', '--player-external-http',
                '--player-external-http-port', port, '--http-header', "Referer=https://1stream.eu", '--http-header', "Origin=https://1stream.eu"],
            stderr=subprocess.PIPE,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            shell=False,
        )
        while True:
            read = current_stream.stdout.readline()
            if read:
                print(read.decode('utf-8'), file=sys.stderr)
                # Might need to tweak this address?
                if f'http://127.0.0.1:{port}' in read.decode('utf-8'):
                    return 'Stream running on port ' + port
            if current_stream.poll() is not None:
                return 'Nothing to poll? Make sure stream has started'
    except Exception as e:
        return 'Error starting stream (make sure it has started): ' + str(e)


@app.route('/', methods=['GET', 'POST'])
def home():
    message = ""
    if request.method == 'POST':
        url = request.form.get('url')
        if url:
            # Start the stream in a separate thread
            message = start_streamlink_stream(url)

            if not message:
                message = 'No streams found for the provided URL'
        else:
            return 'Please enter a valid URL'

    streams = find_available_streams()
    streams_keys = list(streams.keys())
    return render_template('index.html', streams_keys=streams_keys, message=message)


@app.route('/load-stream', methods=['GET'])
def load_stream():
    # Handle the POST request and process the selected key
    key = request.args.get('key')
    streams = streams = find_available_streams()
    streams_keys = list(streams.keys())

    stream_url = get_stream_url(streams[key])
    print(stream_url, file=sys.stderr)
    # Start the stream in a separate thread
    message = start_streamlink_stream(stream_url)

    if message:
        return render_template('index.html', streams_keys=streams_keys, message=message)
    else:
        return render_template('index.html', streams_keys=streams_keys, message="Error")


if __name__ == '__main__':
    # find_available_streams()
    app.run(host='0.0.0.0', port=5000)
