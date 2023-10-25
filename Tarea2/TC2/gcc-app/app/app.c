#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define PORT 9666
#define BUFFER_SIZE 1024




unsigned int ipToUnsignedInt(const char *ip) {
    unsigned int result = 0;
    int octet = 0;
    int shift = 24;
    char *token, *rest = NULL;
    char ipCopy[strlen(ip) + 1];
    strcpy(ipCopy, ip);

    token = strtok_r(ipCopy, ".", &rest);

    while (token != NULL && octet < 4) {
        int value = atoi(token);
        if (value < 0 || value > 255) {
            printf("Invalid IP address\n");
            return 0;
        }
        result |= (value << shift);
        shift -= 8;
        octet++;
        token = strtok_r(NULL, ".", &rest);
    }

    if (octet != 4) {
        printf("Invalid IP address\n");
        return 0;
    }

    return result;
}


char* unsignedIntToIP(unsigned int ip) {
    char *ipString = (char *)malloc(16 * sizeof(char)); // Sufficient for IPv4 addresses
    if (ipString == NULL) {
        perror("Memory allocation error");
        exit(EXIT_FAILURE);
    }

    snprintf(ipString, 16, "%d.%d.%d.%d", (ip >> 24) & 0xFF, (ip >> 16) & 0xFF, (ip >> 8) & 0xFF, ip & 0xFF);
    
    return ipString;
}


int main() {
    int server_socket, client_socket;
    struct sockaddr_in server_address, client_address;
    socklen_t client_address_length = sizeof(client_address);

    // Create the socket
    server_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (server_socket < 0) {
        perror("Error in socket creation");
        exit(1);
    }

    // Bind the socket to a specific port
    server_address.sin_family = AF_INET;
    server_address.sin_port = htons(PORT);
    server_address.sin_addr.s_addr = INADDR_ANY;
    if (bind(server_socket, (struct sockaddr*)&server_address, sizeof(server_address)) < 0) {
        perror("Error in binding");
        exit(1);
    }

    // Listen for incoming connections
    if (listen(server_socket, 5) < 0) {
        perror("Error in listening");
        exit(1);
    }

    printf("Server listening on port %d...\n", PORT);
    int alive = 1;
    char *command, *param1, *param2, *param3, *param4, *param5, *param6;
    unsigned int ipBin;
    unsigned int maskBin;
    unsigned int res;
    while (alive) {
        // Accept a client connection
        client_socket = accept(server_socket, (struct sockaddr*)&client_address, &client_address_length);
        if (client_socket < 0) {
            perror("Error in accepting");
            continue;
        }
        

        char buffer[BUFFER_SIZE];
        char msgToClient[BUFFER_SIZE];
        memset(msgToClient, 0, sizeof msgToClient);
        strcpy(msgToClient, "Hello, client! This is the server.");
        ssize_t bytes_received;

        while ((bytes_received = recv(client_socket, buffer, sizeof(buffer), 0)) > 0) {
            buffer[bytes_received] = '\0'; // Null-terminate the received data.

            memset(msgToClient, 0, sizeof msgToClient);
            
            command = strtok(buffer, " ");

            if (command == NULL) {
                continue;
            }
            if (strcmp(command, "\n") == 0) {
                continue;
            }
            if (strcmp(command, "exit") == 0) {
                printf("Exiting");
                alive = 0;
                break;
            }

            else if (strcmp(command, "GET") == 0) {
                param1 = strtok(NULL, " ");
                param2 = strtok(NULL, " ");
                param3 = strtok(NULL, " ");
                param4 = strtok(NULL, " ");
                param5 = strtok(NULL, " ");
                if (param1 != NULL && param2 != NULL && param3 != NULL && param4 != NULL) {

                    char ip_address[INET_ADDRSTRLEN]; // Buffer to store the IP address

                    struct in_addr host, mask, broadcast;


                    //GET BROADCAST IP 10.8.2.5 MASK /29
                    if (strcmp(param1, "BROADCAST") == 0) {
                        if (strcmp(param2, "IP") == 0 && strcmp(param4, "MASK") == 0) {
                            ipBin = ipToUnsignedInt(param3);
                            //inet_pton(AF_INET, param3, &host);
                            //Si la mascara esta en modo CIDR hace esto
                            if(param5[0] == '/'){
                                //mask.s_addr = ~(0xffffffff >> atoi(param5+1));
                                maskBin = ~(0xffffffff >> atoi(param5+1));
                            }
                            //Si no hace esto
                            else {
                                //inet_pton(AF_INET, param5, &mask);
                                maskBin = ipToUnsignedInt(param5);
                            }
                            //broadcast.s_addr = host.s_addr | mask.s_addr; //Se supone que el broadcast es = host O no mask
                            //inet_ntop(AF_INET, &broadcast, ip_address, INET_ADDRSTRLEN);
                            res = ipBin | ~maskBin;
                            strcpy(msgToClient, unsignedIntToIP(res));
                            send(client_socket, msgToClient, strlen(msgToClient), 0);
                        }
                        else {
                            strcpy(msgToClient, "error en la ejecucion de broadcast problema con parametros\n");
                            send(client_socket, msgToClient, strlen(msgToClient), 0);
                        }
                    }
                        //GET NETWORK NUMBER IP 10.8.2.5 MASK /29
                    else if (strcmp(param1, "NETWORK") == 0) {
                        if (strcmp(param2, "NUMBER") == 0 && strcmp(param3, "IP") == 0 && strcmp(param5, "MASK") == 0) {
                            ipBin = ipToUnsignedInt(param4);
                            param6 = strtok(NULL, " ");
                            //Si la mascara esta en modo CIDR hace esto
                            if(param6[0] == '/'){
                                maskBin = ~(0xffffffff >> atoi(param6+1));
                            }
                            //Si no hace esto
                            else {
                                maskBin = ipToUnsignedInt(param6);
                            }
                            res = ipBin & maskBin;
                            strcpy(msgToClient, unsignedIntToIP(res));
                            
                            send(client_socket, msgToClient, strlen(msgToClient), 0);
                        }
                        else {
                            strcpy(msgToClient, "error en la ejecucion de network, problema con parametros\n");
                            send(client_socket, msgToClient, strlen(msgToClient), 0);
                        }
                    }


                    //GET HOSTS RANGE IP 10.8.2.5 MASK /29
                    else if (strcmp(param1, "HOSTS") == 0) {
                        if (strcmp(param2, "RANGE") == 0 && strcmp(param5, "MASK") == 0) {
                            ipBin = ipToUnsignedInt(param4);
                            //inet_pton(AF_INET, param4, &host);
                            param6 = strtok(NULL, " ");
                            //Si la mascara esta en modo CIDR hace esto
                            if(param6[0] == '/'){
                                maskBin = ~(0xffffffff >> atoi(param6+1));
                            }
                            //Si no hace esto
                            else {
                                maskBin = ipToUnsignedInt(param6);
                            }
                            res = ipBin & maskBin;
                            strcpy(msgToClient, "de ");
                            strcat(msgToClient, unsignedIntToIP(res+1));

                            res = ipBin | ~maskBin;
                            strcat(msgToClient, " a ");
                            strcat(msgToClient, unsignedIntToIP(res-1));

                            send(client_socket, msgToClient, strlen(msgToClient), 0);
                        }
                        else {
                            strcpy(msgToClient, "error en la ejecucion de Host range problema con parametros\n");
                            send(client_socket, msgToClient, strlen(msgToClient), 0);
                        }
                    }
                    else if (strcmp(param1, "RANDOM") == 0) {
                        // Handle the GET RANDOM SUBNETS NETWORK NUMBER command
                        strcpy(msgToClient, "no implementado");
                        send(client_socket, msgToClient, strlen(msgToClient), 0);
                    }

                }
                else{
                    strcpy(msgToClient, "Comando incompleto");
                    send(client_socket, msgToClient, strlen(msgToClient), 0);
                }
        
            }else{
                strcpy(msgToClient, "Comando no reconocido");
                send(client_socket, msgToClient, strlen(msgToClient), 0);
            }

        }

        close(client_socket);
    }

    close(server_socket);
    return 0;
}


