
class Biquad(object):

    def __init__(self,a_param,b_param):
        self.inputsamples = [0,0,0]
        self.outputsamples = [0,0,0]

        self.b = [b_param[0],b_param[1],b_param[2]]
        self.a = [a_param[0] ,a_param[1],a_param[2]]
        return

    def step(self,sample):
        self.inputsamples = [sample,self.inputsamples[0],self.inputsamples[1]]
        output = self.b[0]*self.inputsamples[0]+self.b[1]*self.inputsamples[1]+self.b[2]*self.inputsamples[2]-self.a[1]*self.outputsamples[1]-self.a[2]*self.outputsamples[2]
        self.outputsamples = [output,self.outputsamples[0],self.outputsamples[1]]
        return output


