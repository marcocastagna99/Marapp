import dotenv from 'dotenv';
dotenv.config();  // Carica le variabili d'ambiente

import express from 'express';
import multer from 'multer';
import fetch from 'node-fetch';  // Per fare la richiesta HTTP a Imgur

const app = express();
const port = process.env.PORT || 3000;

// Configurazione per multer (per gestire l'upload dei file)
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

app.post('/api/upload', upload.single('image'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No image uploaded' });
  }

  try {
    console.log('File uploaded:', req.file);  // Log del file ricevuto

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
    if (data.success) {
      const uploadedImageUrl = data.data.link;  // URL dell'immagine caricata
      res.status(200).json({ imageUrl: uploadedImageUrl });
    } else {
      res.status(500).json({ error: 'Error uploading image to Imgur' });
    }
  } catch (error) {
    console.error('Error during upload:', error);
    res.status(500).json({ error: 'Error uploading image to Imgur' });
  }
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
