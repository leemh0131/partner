package com.ensys.qray.security;


import java.io.UnsupportedEncodingException;
import java.security.DigestException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class PasswordDeriveBytes {
    private static final String DEFAULT_ENCODING = "UTF-8";
    private String HashNameValue;
    private byte[] SaltValue;
    private int IterationsValue;
    private MessageDigest hash;
    private int state;
    private byte[] password;
    private byte[] initial;
    private byte[] output;
    private byte[] firstBaseOutput;
    private int position;
    private int hashnumber;
    private int skip;

    public PasswordDeriveBytes(String strPassword, byte[] rgbSalt) {
        Prepare(strPassword, rgbSalt, "SHA-1", 100);
    }

    public PasswordDeriveBytes(String strPassword, byte[] rgbSalt,
                               String strHashName, int iterations) {
        Prepare(strPassword, rgbSalt, strHashName, iterations);
    }

    public PasswordDeriveBytes(byte[] password, byte[] salt) {
        Prepare(password, salt, "SHA-1", 100);
    }

    public PasswordDeriveBytes(byte[] password, byte[] salt, String hashName,
                               int iterations) {
        Prepare(password, salt, hashName, iterations);
    }

    private void Prepare(String strPassword, byte[] rgbSalt,
                         String strHashName, int iterations) {
        if (strPassword == null) {
            throw new NullPointerException("strPassword");
        }
        byte[] pwd = null;
        try {
            pwd = strPassword.getBytes("UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        Prepare(pwd, rgbSalt, strHashName, iterations);
    }

    private void Prepare(byte[] password, byte[] rgbSalt, String strHashName,
                         int iterations) {
        if (password == null) {
            throw new NullPointerException("password");
        }
        this.password = password;
        this.state = 0;
        setSalt(rgbSalt);
        setHashName(strHashName);
        setIterationCount(iterations);
        this.initial = new byte[this.hash.getDigestLength()];
    }

    public byte[] getSalt() {
        if (this.SaltValue == null)
            return null;
        return this.SaltValue;
    }

    public void setSalt(byte[] salt) {
        if (this.state != 0) {
            throw new SecurityException(
                    "Can't change this property at this stage");
        }
        if (salt != null)
            this.SaltValue = salt;
        else
            this.SaltValue = null;
    }

    public String getHashName() {
        return this.HashNameValue;
    }

    public void setHashName(String hashName) {
        if (hashName == null)
            throw new NullPointerException("HashName");
        if (this.state != 0) {
            throw new SecurityException(
                    "Can't change this property at this stage");
        }
        this.HashNameValue = hashName;
        try {
            this.hash = MessageDigest.getInstance(hashName);
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
    }

    public int getIterationCount() {
        return this.IterationsValue;
    }

    public void setIterationCount(int iterationCount) {
        if (iterationCount < 1)
            throw new NullPointerException("HashName");
        if (this.state != 0) {
            throw new SecurityException(
                    "Can't change this property at this stage");
        }
        this.IterationsValue = iterationCount;
    }

    public byte[] getBytes(int cb) throws DigestException {
        if (cb < 1) {
            throw new IndexOutOfBoundsException("cb");
        }

        if (this.state == 0) {
            Reset();
            this.state = 1;
        }

        byte[] result = new byte[cb];
        int cpos = 0;

        int iter = Math.max(1, this.IterationsValue - 1);

        if (this.output == null) {
            this.output = this.initial;

            for (int i = 0; i < iter - 1; ++i) {
                this.output = this.hash.digest(this.output);
            }
        }

        while (cpos < cb) {
            byte[] output2 = null;
            if (this.hashnumber == 0) {
                output2 = this.hash.digest(this.output);
            } else if (this.hashnumber < 1000) {
                byte[] n = Integer.toString(this.hashnumber).getBytes();
                output2 = new byte[this.output.length + n.length];
                for (int j = 0; j < n.length; ++j) {
                    output2[j] = n[j];
                }
                System.arraycopy(this.output, 0, output2, n.length,
                        this.output.length);

                output2 = this.hash.digest(output2);
            } else {
                throw new SecurityException("too long");
            }

            int rem = output2.length - this.position;
            int l = Math.min(cb - cpos, rem);
            System.arraycopy(output2, this.position, result, cpos, l);

            cpos += l;
            this.position += l;
            while (this.position >= output2.length) {
                this.position -= output2.length;
                this.hashnumber += 1;
            }
        }

        if (this.state == 1) {
            if (cb > 20)
                this.skip = (40 - result.length);
            else {
                this.skip = (20 - result.length);
            }
            this.firstBaseOutput = new byte[result.length];
            System.arraycopy(result, 0, this.firstBaseOutput, 0, result.length);
            this.state = 2;
        } else if (this.skip > 0) {
            byte[] secondBaseOutput = new byte[this.firstBaseOutput.length
                    + result.length];
            System.arraycopy(this.firstBaseOutput, 0, secondBaseOutput, 0,
                    this.firstBaseOutput.length);
            System.arraycopy(result, 0, secondBaseOutput,
                    this.firstBaseOutput.length, result.length);
            System.arraycopy(secondBaseOutput, this.skip, result, 0, this.skip);
            this.skip = 0;
        }
        return result;
    }

    public void Reset() throws DigestException {
        this.state = 0;
        this.position = 0;
        this.hashnumber = 0;
        this.skip = 0;

        if (this.SaltValue != null) {
            this.hash.update(this.password, 0, this.password.length);
            this.hash.update(this.SaltValue, 0, this.SaltValue.length);
            this.hash.digest(this.initial, 0, this.initial.length);
        } else {
            this.initial = this.hash.digest(this.password);
        }
    }
}