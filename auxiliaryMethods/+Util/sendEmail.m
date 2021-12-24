function [status, cmdout] = sendEmail(email,subjectText)
% Description:
%   This function allows you to send email via matlab
% Input:
%   email: string, with destination email id eg. 'sahil.loomba@brain.mpg.de'
%   subjectText: string, text for your email subject eg. 'hello world, I am a computer.'
% Output:
%   status: delivery status of the email

command = ['mail -s ', '"', subjectText, '"', ' ', email, ' ', '< /dev/null'];
[status,cmdout] = system(command,'-echo')


end
