
(async function(){
    try{

        // donneee de locaalsation

        const reponse = await fetch('https://ipapi.co/json/');
        const donnees = await reponse.json();

        // CREATION DE L'OBJET A ENVOYER
        const envoyer = {
            page:window.location.pathname,
            navigateur:navigator.userAgent,
            date:new Date().toLocaleString(),
            pays:donnees.country_name || 'Inconnu',
        }

        // Envoi des donnees a google sheet
        await fetch('https://script.googleapis.com/v1/scripts/AKfycbw80F4cNrSfS73qWg8CDitIoN2bWA2PXed1ekco6EqC1YOLKfKgKJgaCUGRtyEPxPcn:run',{
            method:'POST',
            headers:{
                "content-type":"application/json"
            },
            body:JSON.stringify(envoyer)

        });

        console.log("Données de suivi envoyées avec succès");
    }catch(err){
        console.log("Une erreur s'est produite")
    }














})