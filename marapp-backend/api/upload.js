import dotenv from 'dotenv';
dotenv.config();  // Carica le variabili d'ambiente

import multer from 'multer';
import fetch from 'node-fetch';  // Per fare la richiesta HTTP a Imgur

// Configurazione per multer (per gestire l'upload dei file)
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// Funzione principale
const uploadImage = async (req, res) => {
  if (req.method === 'POST') {
    // Usa multer per caricare l'immagine
    upload.single('image')(req, res, async (err) => {
      if (err) {
        return res.status(400).json({ error: 'Error uploading file' });
      }

      try {
        const base64Image = req.file.buffer.toString('base64');  // Converte l'immagine in base64

        // Invia l'immagine a Imgur
        const response = await fetch('https://api.imgur.com/3/image', {
          method: 'POST',
          headers: {
            'Authorization': process.env.IMGUR_ACCESS_TOKEN,  // Usa l'Access Token dall'ambiente
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            image: base64Image,
            type: 'base64',
          }),
        });

        const data = await response.json();
        const uploadedImageUrl = data.data.link;  // URL dell'immagine caricata

        // Rispondi al client con l'URL dell'immagine
        res.status(200).json({ imageUrl: uploadedImageUrl });
      } catch (error) {
        res.status(500).json({ error: 'Error uploading image to Imgur' });
      }
    });
  } else {
    res.status(405).json({ error: 'Method Not Allowed' });
  }
};

export default uploadImage;  // Esporta la funzione
