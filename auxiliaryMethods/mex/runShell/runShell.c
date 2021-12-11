/*
    runShell
   
    Invoke Bourne shell commands from MATLAB without that crazy
    standard input forwarding. This way we hope to avoid corruptions
    of the output.

    Note
        According to the POSIX standard, the specified command is
        interpreted by /bin/sh. This shell might be different from
        the user's login shell.
   
    Written by
        Alessandro Motta <alessandro.motta@brain.mpg.de>
*/

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* MEX related */
#include "mex.h"
#include "matrix.h"

/* constants */
#define BUF_SIZE 512

int runsh(const char * cmd, char ** out, size_t * out_size) {
	/* stack alloc */
	char buf[BUF_SIZE];

	/* heap alloc */
	char * data = malloc(BUF_SIZE);
	assert(data != NULL);

	size_t data_pos = 0;
	size_t data_size = BUF_SIZE;

	FILE * h = popen(cmd, "r");
	assert(h != NULL);

	do {
		/* try to read output */
		size_t read = fread(buf, 1, BUF_SIZE - 1, h);

		/* are we done here? */
		if (read == 0)
			continue;

		if (data_pos + read > data_size) {
			data_size = data_size << 1;
			data = realloc(data, data_size);
			assert(data != NULL);
		}

		/* copy to heap */
		memcpy(&data[data_pos], buf, read);
		data_pos = data_pos + read;
	} while (!feof(h) && !ferror(h));

	/* just to be sure */
	data[data_pos] = '\0';
	data_pos++;

	/* clean up */
	int err = pclose(h);

	/* set outputs */
	*out = data;
	*out_size = data_pos;

	return err;
}

void mexFunction(int nlhs, mxArray ** plhs,
                 int nrhs, const mxArray ** prhs) {
	assert(nrhs >= 1);
	assert(nlhs >= 2);

	const mxArray * cmd_arr = prhs[0];
	assert(mxIsChar(cmd_arr) && !mxIsEmpty(cmd_arr));

	/* allocate string */
	char * cmd = mxArrayToString(cmd_arr);
	assert(cmd != NULL);

	char * out;
	size_t out_size;

	/* run command */
	int err = runsh(cmd, &out, &out_size);

	/* set outputs */
	plhs[0] = mxCreateDoubleScalar(err);
	plhs[1] = mxCreateString(out);

	/* clean up */
	free(out);
} 

