from flask import Flask, request
import os

app = Flask(__name__)

@app.route('/')
def deel_ip():
    # Get client IP from X-Forwarded-For header (for load balancers) or remote_addr
    client_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
    if ',' in client_ip:
        client_ip = client_ip.split(',')[0].strip()
    
    # deel the IP address
    deeld_ip = '.'.join(client_ip.split('.')[::-1])
    
    return f"Your IP: {client_ip}\ndeeld IP: {deeld_ip}\n"

@app.route('/health')
def health():
    return "OK"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))