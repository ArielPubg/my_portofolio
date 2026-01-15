
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
        await fetch('https://script.google.com/macros/s/AKfycbwUMZ6jRifKFhTWGplIQt12yKdTFnXV4J7Jd9-cT0LRLXXLzc5H0BhKHpCOHix7oDVPIw/exec',{
            method:'POST',
            headers:{
                "content-type":"application/json"
            },
            body:JSON.stringify(envoyer)

        });

        console.log("Données de suivi envoyées avec succès");
    }catch(err){
        console.log("Une erreur s'est produite");
    }


})