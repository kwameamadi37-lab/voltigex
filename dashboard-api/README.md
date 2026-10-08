//Here you get all you need for your application 

1-Connexion et obtention des infos de l'user : /****** #API LOGIN | mobileLogin() */ => AppController.php : POST

Variables à envoyer : email,password

http://127.0.0.1:8000/api/auth/mobile-login

Reponse type : {"success":true,"message":"Connexion r\u00e9ussie.","data":{"user":{"id":2,"email":"kpade2000@gmail.com","phone":"+33789867679","alias":"kpade2000","role":"user","email_verified":false,"phone_verified":false,"email_and_phone_verified":false,"kyc_approved":false,"kyc_status":"pending","fully_verified":false},"token":"10|othAOj1l5dZCCR2iYyT6cke6cgW3WSbE6XD6c5Vf3a6cd7d8"}}

2-Selection d'un utilisateur unique :  /*** #USER INFO | getUserInfo($id) */ => AppController.php : GET

Variables à envoyer : id de l'utilisateur

http://127.0.0.1:8000/api/user-info/{id}

Reponse type : {"success":true,"data":{"id":2,"role":"user","nom":"azace","prenom":"azzzz","profession":null,"profession_detaille":"aaaa","date_naissance":"2025-10-17T00:00:00.000000Z","lieu_naissance":"zzzzzzz","nationalite":"CH","phone":"+33789867679","alias":"kpade2000","date_exp":null,"solde":"0.00","salaire":"0.00","revenus_mensuels":"1222.00","situation_familiale":"celibataire","nombre_enfants":2,"piece_recto":null,"piece_verso":null,"email":"kpade2000@gmail.com","devise":"\u20ac","card_active":false,"email_verified_at":null,"phone_verified_at":null,"adresse_complete":"zzzzzz","code_postal":"aaa","ville":"aaa","pays":"ES","kyc_status":"approved","kyc_submitted_at":null,"kyc_approved_at":null,"kyc_rejection_reason":null,"ip_address":null,"last_ip_address":"127.0.0.1","country":null,"last_country":null,"is_blocked":false,"is_online":true,"created_at":"2025-10-18T20:36:37.000000Z","updated_at":"2025-10-27T14:40:35.000000Z"}}


3-Obtention du status du compte :  /*** #ACCOUNT STATUS | getUserInfo($id) */ => AppController.php : GET

Variables à envoyer : id de l'utilisateur

http://127.0.0.1:8000/api/user-account/{id}/status

Reponse type : {"success":true,"data":{"is_blocked":false,"kyc_status":"pending"}}


4-Activation de carte : /*** #CARD ACTIVATION | activateCard(Request $request, $id) */ => AppController.php : POST

Variables à envoyer : card_number, date_exp, cvv, id ( id de l'utilisateur )

http://127.0.0.1:8000/api/user/{id}/card/activate


5-




