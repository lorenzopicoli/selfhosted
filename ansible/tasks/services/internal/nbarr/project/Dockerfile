# Use alpine as the base image
FROM python:3.9-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file to the working directory
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Flask application code to the working directory
COPY src/ .

# Expose port 5000 for the Flask server
EXPOSE 5000
EXPOSE 5946

# Set the command to start the Flask server
CMD ["python", "app.py"]
