from Crypto.Cipher import AES
import base64
import os

BLOCK_SIZE = 16
PADDING = '\0'
pad_it = lambda s: s+(16 - len(s)%16)*PADDING
key = b'xlszyzxgejie2019'
iv = b'1236987450123456'


def pad_byte(b):
    bytes_num_to_pad = BLOCK_SIZE - (len(b) % BLOCK_SIZE)
    byte_to_pad = bytes([bytes_num_to_pad])
    padding = byte_to_pad * bytes_num_to_pad
    padded = b + padding
    return padded

def encrypt_aes(sourceStr):
    generator = AES.new(key, AES.MODE_CFB, iv, segment_size=128)
    padded = pad_byte(sourceStr.encode('utf-8'))
    crypt = generator.encrypt(padded)
    cryptedStr = base64.b64encode(crypt)
    return cryptedStr.decode('utf-8')


def decrypt_aes(cryptedStr):
    generator = AES.new(key, AES.MODE_CFB, iv,segment_size=128)
    cryptedStr = base64.b64decode(cryptedStr)
    recovery = generator.decrypt(cryptedStr)
    decryptedStr = recovery.rstrip(PADDING.encode('utf-8'))
    return decryptedStr

sourceStr = 'respROd_123'


print('明文:',sourceStr)
print('加密串:',encrypt_aes(sourceStr))
print('解密串:',decrypt_aes(encrypt_aes(sourceStr)).decode('utf-8'))