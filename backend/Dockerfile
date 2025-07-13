# --- STAGE 1: The Builder ---
# We use a full Python image to compile our dependencies. This stage has all the build tools.
FROM python:3.9-slim as builder

# Set the working directory
WORKDIR /app

# Create and activate a virtual environment. This isolates our dependencies
# and keeps the final image's global python environment clean.
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy ONLY the requirements file to leverage Docker layer caching.
# If this file doesn't change, Docker won't re-run the pip install command.
COPY backend/requirements.txt .

# Install dependencies into the virtual environment.
RUN pip install --no-cache-dir -r requirements.txt

# --- STAGE 2: The Final Image ---
# We now switch to a fresh, minimal base image for the production container.
FROM python:3.9-slim

# Set the working directory.
WORKDIR /app

# Copy the entire pre-built virtual environment from the 'builder' stage.
# This avoids needing build tools in our final image, making it smaller and more secure.
COPY --from=builder /opt/venv /opt/venv

# Set the venv path for the final image. Any command will now use the python/pip from our venv.
ENV PATH="/opt/venv/bin:$PATH"

# Create a dedicated, non-root user to run the application.
# This is a critical security practice to limit the blast radius if the app is compromised.
RUN useradd --create-home appuser
USER appuser

# Copy the application source code into the final image.
COPY ./backend/app /app/app
COPY ./backend/main.py .

# Expose the port the application will run on.
EXPOSE 8000

# The command to run when the container starts.
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]