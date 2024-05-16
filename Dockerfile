# Use the official Python image from the Docker Hub
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt requirements.txt

# Install any dependencies specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container at /app
COPY . .

# Set environment variables
ENV MONGO_USERNAME=<your-username>
ENV MONGO_PASSWORD=<your-password>

# Run the Python script when the container launches
CMD ["python", "import_yaml2.py"]
