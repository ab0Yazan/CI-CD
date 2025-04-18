############## base stage ###############################################
FROM node:22.14.0-alpine AS base
WORKDIR /usr/src
COPY ./frontend .
RUN npm install
############# dev stage #################################################
FROM base AS dev
EXPOSE 80
CMD [ "npm", "run", "serve" ]
############ build stage ################################################
FROM base AS build
RUN npm run build
########### prod stage ##################################################
FROM nginx:1.25.1-alpine AS prod
COPY --from=build /usr/src/dist /usr/share/nginx/html
COPY ./deployment/config/nginx/nginx-frontend.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
########## end of file ##################################################
