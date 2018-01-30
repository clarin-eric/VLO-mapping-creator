/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package eu.clarin.vlo.mapping;

import org.junit.*;

/**
 *
 * @author menwin
 */
public class TestVLOMappingCreator {

    @Before
    public void setUp() {
        try {
        } catch(Exception e) {
            System.err.println("!ERR: couldn't setup the testing environment!");
            System.err.println(""+e);
            e.printStackTrace(System.err);
        }
    }

    @After
    public void tearDown() {
    }

    @Test
    public void testResourceTypes() throws Exception {
        System.out.println("* BEGIN: ResourceTypes tests");

        System.out.println("*  END : ResourceTypes tests");
    }

}
