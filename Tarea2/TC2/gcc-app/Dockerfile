FROM gcc:4.9
WORKDIR /app
COPY app/. .
# Expose port 9666
EXPOSE 9666

RUN gcc -o appc app.c
CMD ["./appc"]