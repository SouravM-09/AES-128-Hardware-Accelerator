`timescale 1ns/1ps

module tb_AES_core;

    reg  [127:0] plaintext;
    reg  [127:0] key;
    wire [127:0] ciphertext;

    // Instantiate your AES core
    AES_core uut (
        .plaintext(plaintext),
        .key(key),
        .ciphertext(ciphertext)
    );

    initial begin
        // Standard AES test vector
        plaintext = 128'h00112233445566778899AABBCCDDEEFF;
        key       = 128'h000102030405060708090A0B0C0D0E0F;

        // Wait for computation
        #10;

        // Display result
        $display("Plaintext  = %h", plaintext);
        $display("Key        = %h", key);
        $display("Ciphertext = %h", ciphertext);

        // Expected result
        if (ciphertext == 128'h69C4E0D86A7B0430D8CDB78070B4C55A)
            $display("? AES Correct!");
        else
            $display("? AES Incorrect!");

        $stop;
    end

endmodule