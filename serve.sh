#!/bin/sh

# Load environment variables
export $(cat .env | xargs)
# Start the Phoenix server
mix phx.server