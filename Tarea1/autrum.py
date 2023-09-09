# python3 autrum.py
import tkinter as tk
import numpy as np
import sounddevice as sd
from tkinter.filedialog import askopenfilename
from tkinter.filedialog import asksaveasfile
from scipy.io import wavfile
from scipy.fft import fft
import matplotlib.pyplot as plt
import threading
import pyaudio
import wave 


#variables
fileName = ""
grabando = threading.Event()

#datos a salvar
audio_data = []
sample_rate = 1
time = 1 
freq_data = []
frequencies = []
positive_frequencies = []
magnitude_spectrum = []

#funciones
def openAudioFile():
    fileName = askopenfilename()
    sample_rate, audio_data = wavfile.read(fileName)
    time = np.arange(0, len(audio_data)) / sample_rate
    procesarAudio(sample_rate, audio_data, time)
    SaveButton["state"] = "normal"


def pararDeGrabar():
    StopRecordButton["state"] = "disabled"
    RecordButton["state"] = "normal"
    #Setea el evento que es argumento del thread de grabar como clear, indicando que el proceso puede detenerse
    grabando.clear()


def grabarAux(grabando):
    audio = pyaudio.PyAudio()
    stream = audio.open(format=pyaudio.paInt16, channels=1,
                        rate=44100, input=True, frames_per_buffer=1024)
    frames = []

    while grabando.is_set():
        data = stream.read(1024)
        frames.append(data)
    
    stream.stop_stream()
    stream.close()
    audio.terminate()
    sound_file = wave.open("MiAudio.wav", "wb")
    sound_file.setnchannels(1)
    sound_file.setsampwidth(audio.get_sample_size(pyaudio.paInt16))
    sound_file.setframerate(44100)
    sound_file.writeframes(b''.join(frames))
    sound_file.close
    return

#inicializa el thread que escribe al archivo salida
def grabar():
    RecordButton["state"] = "disabled"
    StopRecordButton["state"] = "normal"
    grabando.set()
    my_thread = threading.Thread(target=grabarAux, args=(grabando,))
    my_thread.start()


def procesarAudio(sample_rate, audio_data, time):
    #Hace sonar el audio
    sd.play(audio_data, sample_rate)

    #Figura de raw data
    plt.figure(figsize=(10, 4))
    plt.plot(time,audio_data, lw=0.5)
    plt.title("amplitud y tiempo")
    plt.ylabel('amplitud')
    plt.xlabel('tiempo')
    plt.grid()

    #fast fourier transform
    freq_data = fft(audio_data)
    frequencies = np.fft.fftfreq(len(freq_data), 1/sample_rate)
    positive_frequencies = frequencies[:len(frequencies)//2]
    magnitude_spectrum = np.abs(freq_data[:len(freq_data)//2])

    #figura de frecuencias
    plt.figure(figsize=(10, 4))
    plt.plot(positive_frequencies, magnitude_spectrum, lw=0.5)
    plt.title("amplitud y frecuencias")
    plt.ylabel('amplitud')
    plt.xlabel('frecuencias')
    plt.grid()
    plt.show()


#Funcion de salvar, no funciona correctamente por falta de parametros
def salvar():
    f = asksaveasfile(mode='w', defaultextension=".atm")
    if f is None:
        return
    data = []
    data.append(sample_rate)
    data.append(audio_data)
    data.append(time)
    data.append(freq_data)
    data.append(frequencies)
    data.append(positive_frequencies)
    data.append(magnitude_spectrum)
    print(len(data))
    f.write(str(data))
    f.close()
    RecordButton["state"] = "disabled"


#Pantalla principal
root = tk.Tk()
root.geometry("500x500")
root.title("Autrum")


#Botones, posicion texto y funciones
OpenFileButton = tk.Button(root, text = "Abrir archivo", command = openAudioFile)
OpenFileButton.pack(padx= 10, pady= 10)

RecordButton = tk.Button(root, text = "Grabar nuevo audio", command = grabar)
RecordButton.pack(padx= 10, pady= 10)

StopRecordButton = tk.Button(root, text = "Parar de grabar", command = pararDeGrabar, state="disabled")
StopRecordButton.pack(padx= 10, pady= 10)

SaveButton = tk.Button(root, text = "Salvar Autrum", state="disabled", command = salvar)
SaveButton.pack(padx= 10, pady= 10)

root.mainloop()

